-- Base code came from 'cc-memdb': https://github.com/GabrielleAkers/cc-memdb
-- This installer can download all the needed API files

---@class File
---@field name string File's name
---@field path string Path to that file, from repo's root
---@field url string Link to access the raw code of that file
---@field size number Size of that file (in bytes)


local installer = {}
installer.printStatus = true
installer.githubRawPath = "https://raw.githubusercontent.com/Susjin/cc-tweaked-apis/"
installer.githubAPIPath = "https://api.github.com/repos/Susjin/cc-tweaked-apis/git/trees/"
installer.whitelistButton = {
    "ButtonAPI",
    "Button.lua",
    "ButtonsManager.lua",
    "init.lua"
}

---Takes a string and divide it onto a table using a given delimiter.  
---Eg. using '/' as a delimiter:  
---`"ButtonAPI/Button.lua" -> {"ButtonAPI", "Button.lua"}`
---@param string string String to be divided onto a table
---@param delimiter string Delimiter used to determine how each word will split
---@return string[] result A table containing each string divided  
function installer.split(string, delimiter)
    local result = {}
    if (string) then
        for match in (string .. delimiter):gmatch("(.-)" .. delimiter) do
            table.insert(result, match)
        end
    end
    return result
end

---Used to check if a given file path is on the whitelist to download
---@param filePath string Complete path for a file
---@param whitelist string[] Table containing all allowed files/folders to be downloaded
---@return boolean
function installer.isInWhitelist(filePath, whitelist)
    if (whitelist) then
        local filePathParts = installer.split(filePath, "/")
        if #filePathParts > 1 then
            local current, iterations, required = 0, 1, #filePathParts
            while iterations <= #whitelist do
                if filePathParts[current+1] == whitelist[iterations] then
                    current = current + 1
                    iterations = 1
                else
                end
                iterations = iterations + 1
                if current == required then return true end
            end
        else
            for _, whitelistedFile in ipairs(whitelist) do
                if (whitelistedFile == filePathParts[1]) then
                    return true
                end
            end
        end
    end
    return false
end

---Prints a status message.  
---If the `installer.printStatus` atribute contains a function, execute it.  
---Else, if it's true, just print the args given. If it's false, doesn't do anything
---@param ... any Arguments passed.
function installer.printStatus(...)
    if (type(installer.printStatus) == "function") then
        installer.printStatus(...)
    elseif (installer.printStatus) then
        print(...)
    end
end

---Get all the content from a given URL.  
---Different from the default `http.get()`, this checks if the website is loaded
---@param url string URL of the website to get content
---@param file boolean If *true*, download the raw file.<br>If *false*, download a fileTree
---@param dirName string? Only applicable if `file == false`. Just show the dirName on the print message
---@return string?
function installer.get(url, file, dirName)
    if file then
        installer.printStatus("Downloading " .. url)
    else
        installer.printStatus("Receiving file tree for " .. (dirName and "cc-tweaked-apis/" .. dirName or "cc-tweaked-apis"))
    end
    
    local response, failedMessage = http.get(url)
    if not response then error("GET request failed! " .. failedMessage) end
    local contents = response.readAll()
    response.close()

    return contents
end

--- Creates a filetree based on the given API link for the github project
--- @param url string The URL of the GitHub API for a specific path
--- @param branch string The Branch's name 
--- @param dirName string A name for a folder to save the files
--- @param whitelist string[]? A table containing all the strings allowed to be downloaded
--- @return File[]|table<string, File[]> tree An array of tables containing all files and folders to be downloaded
function installer.createTree(url, branch, dirName, whitelist)
    ---@type File[]|table
    local tree = {}
    whitelist = whitelist or {}
    dirName = dirName or ""
    
    local requestAPIData = installer.get(url, false, dirName)
    local requestedTree = textutils.unserialiseJSON(requestAPIData and requestAPIData or {tree = ""}).tree

    for _, treeBranch in pairs(requestedTree) do
        if (treeBranch.type == "blob") then
            local filePath = fs.combine(dirName, treeBranch.path)
            if installer.isInWhitelist(filePath, whitelist) then
                table.insert(tree,
                    {
                        name = treeBranch.path,
                        path = filePath,
                        url = installer.githubRawPath .. branch .. "/" .. filePath,
                        size = treeBranch.size
                    })
            end
        elseif (treeBranch.type == "tree") then
            local dirPath = fs.combine(dirName, treeBranch.path)
            if installer.isInWhitelist(dirPath, whitelist) then
                tree[treeBranch.path] = installer.createTree(treeBranch.url, branch, dirPath, whitelist)
            end
        end
    end
    return tree
end

---Gets the Raw text from all the files from the project
---@param branch string Branch from where the files will be downloaded from
---@param whitelist string[]? A table containing all the strings allowed to be downloaded
---@return table<string, string> project 
function installer.getProjectFiles(branch, whitelist)
    local projectTree = installer.createTree(installer.githubAPIPath .. branch, branch, "", whitelist)
    local project = {}
    --Function needed for parallel downloading
    local function downloadFile(url, path)
        if not url then return end
        project[path] = installer.get(url, true)
    end

    local fileList = {}
    local delay = 0

    for index, fileOrFolder in pairs(projectTree) do
        if (type(index) == "string") then --It is a folder
            for _, file in pairs(fileOrFolder) do
                table.insert(fileList, function()
                    sleep(delay)
                    downloadFile(file.url, file.path)
                end)
                delay = delay + 0.05
            end
        else --It is a file
            table.insert(fileList, function()
                sleep(delay)
                downloadFile(fileOrFolder.url, fileOrFolder.path)
            end)
            delay = delay + 0.05
        end
    end
    parallel.waitForAll(table.unpack(fileList))

    return project
end

---Main functions to download a API from the GitHub.
---@param whitelist string[] The allowed files to be donwloaded. The 1 item determines which API to get
---@param branch string Name of the branch to get the files from
function installer.downloadProject(whitelist, branch)
    local projectDir = whitelist[1] --The first entry on the whitelist table is always the API directory
    if fs.exists(projectDir) then 
        installer.printStatus(string.format("A folder called %s already exists!\nDeleting...", projectDir)) 
        fs.delete(projectDir)
    else
        fs.makeDir(projectDir)
    end
    
    local projectFiles = installer.getProjectFiles(branch, whitelist)

    for fileName, fileContent in pairs(projectFiles) do
        local file = fs.open(fs.combine(projectDir, fileName), "w")
        if file then
            installer.printStatus(string.format("Saving %s to %s/...", fileName, projectDir))
            file.write(fileContent)
            file.close()
        end
    end
    installer.printStatus("Source version successfully downloaded!")
end

installer.downloadProject(installer.whitelistButton, "dev")

return installer