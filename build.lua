function mtime(file)
    return os.date("%Y-%m-%dT%H:%M:%S+08:00", os.mtime(file))
end

function header(url)
    return format([[
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>xmake</title>
  <link rel="icon" href="/assets/img/favicon.ico">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
  <meta name="description" content="Description">
  <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
  <link href="/assets/npm/github-markdown/github-markdown.min.css" rel="stylesheet">
  <style>
	.markdown-body {
		box-sizing: border-box;
		min-width: 200px;
		max-width: 980px;
		margin: 0 auto;
		padding: 45px;
	}

	@media (max-width: 767px) {
		.markdown-body {
			padding: 15px;
		}
	}
  </style>
</head>
<body>
<article class="markdown-body">
<h4>This is a mirror page, please see the original page: </h4><a href="%s">%s</a>
</br>
    ]], url, url)
end

function tailer()
    return [[
</article>
</body>
</html>]]
end

function ads()
    return [[
<script async type="text/javascript" src="//cdn.carbonads.com/carbon.js?serve=CE7I52QU&placement=xmakeio" id="_carbonads_js"></script>
<style>
#carbonads {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen-Sans, Ubuntu,
  Cantarell, "Helvetica Neue", Helvetica, Arial, sans-serif;
}

#carbonads {
  display: flex;
  max-width: 330px;
  background-color: hsl(0, 0%, 98%);
  box-shadow: 0 1px 4px 1px hsla(0, 0%, 0%, .1);
}

#carbonads a {
  color: inherit;
  text-decoration: none;
}

#carbonads a:hover {
  color: inherit;
}

#carbonads span {
  position: relative;
  display: block;
  overflow: hidden;
}

#carbonads .carbon-wrap {
  display: flex;
}

.carbon-img {
  display: block;
  margin: 0;
  line-height: 1;
}

.carbon-img img {
  display: block;
}

.carbon-text {
  font-size: 13px;
  padding: 10px;
  line-height: 1.5;
  text-align: left;
}

.carbon-poweredby {
  display: block;
  padding: 8px 10px;
  background: repeating-linear-gradient(-45deg, transparent, transparent 5px, hsla(0, 0%, 0%, .025) 5px, hsla(0, 0%, 0%, .025) 10px) hsla(203, 11%, 95%, .4);
  text-align: center;
  text-transform: uppercase;
  letter-spacing: .5px;
  font-weight: 600;
  font-size: 9px;
  line-height: 1;
}
</style>
    ]]
end

-- fix links
function _fixlinks(htmldata)

    -- <a href="/manual/builtin_modules?id=osmv">os.mv</a>
    -- => <a href="/mirror/manual/builtin_modules.html#osmv">os.mv</a>
    htmldata = htmldata:gsub("(href=\"(.-)\")", function(_, href)
        if href:startswith("/") and not href:startswith("/#/") then
            local splitinfo = href:split('?', {plain = true})
            local url = splitinfo[1]
            href = "/mirror" .. url .. ".html"
            if splitinfo[2] then
                local anchor = splitinfo[2]:gsub("id=", "")
                href = href .. "#" .. anchor
            end
            print(" -> fix %s", href)
        end
        return "href=\"" .. href .. "\""
    end)

    -- <h4 id="os-rm">os.rm</h4>
    -- => <h4 id="osrm">os.rm</h4>
    htmldata = htmldata:gsub("(id=\"(.-)\")", function(_, id)
        id = id:gsub("%-", "")
        return "id=\"" .. id .. "\""
    end)
    return htmldata
end

-- generate mirror files and sitemap.xml
-- we need install https://github.com/cwjohan/markdown-to-html first
-- npm install markdown-to-html -g
--
-- Or use showdown-cli https://github.com/showdownjs/showdown
--
function main()
    local siteroot = "https://xmake.io"
    local mirrordir = "mirror"
    local sitemap = io.open("sitemap.xml", 'w')
    sitemap:print([[
<?xml version="1.0" encoding="UTF-8"?>
<urlset
      xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
            http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
    ]])
    sitemap:print([[
<url>
  <loc>%s</loc>
  <lastmod>%s</lastmod>
</url>
]], siteroot, mtime("index.html"))
    os.rm(mirrordir)
    for _, markdown in ipairs(os.files("**.md")) do
        local basename = path.basename(markdown)
        if not basename:startswith("_") then

            -- get the raw url
            if basename == "README" then
                basename = ""
            end
            local url = siteroot .. '/mirror'
            local rawurl = siteroot .. '/#'
            local dir = path.directory(markdown)
            if dir ~= '.' then
                rawurl = rawurl .. '/' .. dir
                url = url .. '/' .. dir
            end
            rawurl = rawurl .. '/' .. basename
            url = url .. '/' .. (basename == "" and "index.html" or (basename .. ".html"))

            -- generate html file
            local htmlfile = path.join(mirrordir, dir, basename == "" and "index.html" or (basename .. ".html"))
            local htmldata = os.iorunv("markdown", {markdown})
            local f = io.open(htmlfile, 'w')
            if f then
                f:write(header(rawurl))
                f:write(ads())
                htmldata = htmldata:gsub("&%a-;", function (w) 
                    local maps = {["&lt;"] = "<", ["&gt;"] = ">", ["&quot;"] = "\""}
                    return maps[w]
                end)
                f:write(_fixlinks(htmldata))
                f:write(tailer())
                f:close()
            end

            --[[
            local tmpfile = os.tmpfile()
            os.mkdir(path.directory(tmpfile))
            os.execv("showdown", {"makehtml", "-i", markdown, "-o", tmpfile})
            local f = io.open(htmlfile, 'w')
            if f then
                f:write(header(rawurl))
                f:write(ads())
                f:write(_fixlinks(io.readfile(tmpfile)))
                f:write(tailer())
                f:close()
            end
            os.rm(tmpfile)]]

            print("build %s => %s, %s", markdown, htmlfile, mtime(htmlfile))
            print("url %s -> %s", url, rawurl)

            -- generate sitemap
            sitemap:print([[
<url>
  <loc>%s</loc>
  <lastmod>%s</lastmod>
</url>
]], url, mtime(htmlfile))
        end
    end
    sitemap:print("</urlset>")
    sitemap:close()
end


