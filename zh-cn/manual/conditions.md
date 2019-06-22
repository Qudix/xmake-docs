---
nav: zh
search: zh
---

## 接口规范

#### 命名规范

接口的命名，是有按照预定义的一些规范来命名的，这样更加方便理解和易于使用，目前命名按照如下一些规则：

| 接口规则                | 描述                                                         |
| ----------------------- | ------------------------------------------------------------ |
| `is_`, `has_`前缀的接口 | 表示为条件判断                                               |
| `set_`前缀的接口        | 表示为覆盖设置                                               |
| `add_`前缀的接口        | 表示为追加设置                                               |
| `s`后缀的接口           | 表示支持多值传入，例如：`add_files("*.c", "test.cpp")`       |
| `on_`前缀的接口         | 表示为覆盖内置脚本                                           |
| `before_`前缀的接口     | 表示为在内置脚本运行前，执行此脚本                           |
| `after_`前缀的接口      | 表示为在内置脚本运行后，执行此脚本                           |
| `scope("name")`的接口   | 表示为定义一个描述域，例如：`target("xxx")`, `option("xxx")` |
| 描述域/描述设置         | 建议缩进表示                                                 |


## 接口文档

#### 条件判断 

条件判断的api，一般用于必须要处理特定平台的编译逻辑的场合。。通常跟lua的if语句配合使用。

| 接口                        | 描述                          | 支持版本                |
| -------------------------   | ----------------------------- | ----------------------- |
| [is_os](#is_os)             | 判断当前构建目标的操作系统    | >= 2.0.1                |
| [is_arch](#is_arch)         | 判断当前编译架构              | >= 2.0.1                |
| [is_plat](#is_plat)         | 判断当前编译平台              | >= 2.0.1                |
| [is_host](#is_host)         | 判断当前主机环境操作系统      | >= 2.1.4                |
| [is_mode](#is_mode)         | 判断当前编译模式              | >= 2.0.1                |
| [is_kind](#is_kind)         | 判断当前编译类型              | >= 2.0.1                |
| [is_option](#is_option)     | 判断选项是否启用              | >= 2.0.1 < 2.2.2 已废弃 |
| [is_config](#is_config)     | 判断指定配置是否为给定的值    | >= 2.2.2                |
| [has_config](#has_config)   | 判断配置是否启用或者存在      | >= 2.2.2                |
| [has_package](#has_package) | 判断依赖包是否被启用或者存在  | >= 2.2.3                |

##### is_os 

###### 判断当前构建目标的操作系统

```lua
-- 如果当前操作系统是ios
if is_os("ios") then
    add_files("src/xxx/*.m")
end
```

目前支持的操作系统有：

* windows
* linux
* android
* macosx
* ios

##### is_arch

###### 判断当前编译架构

用于检测编译配置：`xmake f -a armv7`

```lua
-- 如果当前架构是x86_64或者i386
if is_arch("x86_64", "i386") then
    add_files("src/xxx/*.c")
end

-- 如果当前平台是armv7, arm64, armv7s, armv7-a
if is_arch("armv7", "arm64", "armv7s", "armv7-a") then
    -- ...
end
```

如果像上面那样一个个去判断所有arm架构，也许会很繁琐，毕竟每个平台的架构类型很多，xmake提供了类似[add_files](#targetadd_files)中的通配符匹配模式，来更加简洁的进行判断：

```lua
--如果当前平台是arm平台
if is_arch("arm*") then
    -- ...
end
```

用`*`就可以匹配所有了。。

##### is_plat

###### 判断当前编译平台

用于检测编译配置：`xmake f -p iphoneos`

```lua
-- 如果当前平台是android
if is_plat("android") then
    add_files("src/xxx/*.c")
end

-- 如果当前平台是macosx或者iphoneos
if is_plat("macosx", "iphoneos") then
    add_frameworks("Foundation")
end
```

目前支持的平台有：

* windows
* cross
* linux
* macosx
* android
* iphoneos
* watchos

当然你也可以自己扩展添加自己的平台，甚至直接指定自己的平台名：

```bash
$ xmake f -p other --sdk=...
```

如果指定的平台名不存在，就会自动切到`cross`平台进行交叉编译，但是缺可以通过`is_plat("other")`来判断自己的平台逻辑。

##### is_host

###### 判断当前主机环境的操作系统

有些编译平台是可以在多个不同的操作系统进行构建的，例如：android的ndk就支持linux,macOS还有windows环境。

这个时候就可以通过这个接口，区分当前是在哪个系统环境下进行的构建。

```lua
-- 如果当前主机环境是windows
if is_host("windows") then
    add_includedirs("C:\\includes")
else
    add_includedirs("/usr/includess")
end
```

目前支持的主机环境有：

* windows
* linux
* macosx

你也可以通过[$(host)](#var-host)内置变量或者[os.host](#os-host)接口，来进行获取

##### is_mode

###### 判断当前编译模式

用于检测编译配置：`xmake f -m debug`

编译模式的类型并不是内置的，可以自由指定，一般指定：`debug`, `release`, `profile` 这些就够用了，当然你也可以在xmake.lua使用其他模式名来判断。

```lua
-- 如果当前编译模式是debug
if is_mode("debug") then

    -- 添加DEBUG编译宏
    add_defines("DEBUG")

    -- 启用调试符号
    set_symbols("debug")

    -- 禁用优化
    set_optimize("none")

end

-- 如果是release或者profile模式
if is_mode("release", "profile") then

    -- 如果是release模式
    if is_mode("release") then

        -- 隐藏符号
        set_symbols("hidden")

        -- strip所有符号
        set_strip("all")

        -- 忽略帧指针
        add_cxflags("-fomit-frame-pointer")
        add_mxflags("-fomit-frame-pointer")

    -- 如果是profile模式
    else

        -- 启用调试符号
        set_symbols("debug")

    end

    -- 添加扩展指令集
    add_vectorexts("sse2", "sse3", "ssse3", "mmx")
end
```

##### is_kind

###### 判断当前编译类型

判断当前是否编译的是动态库还是静态库，用于检测编译配置：`xmake f -k [static|shared]`

一般用于如下场景：

```lua
target("test")

    -- 通过配置设置目标的kind
    set_kind("$(kind)")
    add_files("src/*c")

    -- 如果当前编译的是静态库，那么添加指定文件
    if is_kind("static") then
        add_files("src/xxx.c")
    end
```

编译配置的时候，可手动切换，编译类型：

```bash
# 编译静态库
$ xmake f -k static
$ xmake
```

```bash
# 编译动态库
$ xmake f -k shared
$ xmake
```

##### is_option

###### 判断选项是否启用

<p class="tips">
此接口在2.2.2版本之后已经弃用，请使用[has_config](#has_config)来代替。
</p>

用于检测自定义的编译配置选型：`xmake f --xxxx=y`

如果某个自动检测选项、手动设置选项被启用，那么可以通过`is_option`接口来判断，例如：

```lua
-- 如果手动启用了xmake f --demo=y 选项
if is_option("demo") then

    -- 编译demo目录下的代码
    add_subdirs("src/demo")
end
```

##### is_config

###### 判断指定配置是否为给定的值

此接口从2.2.2版本开始引入，用于判断指定配置是否为给定的值，可用于描述域。

例如：

```console
$ xmake f --test=hello1
```

```lua
-- 自定义一个配置选项到命令行菜单
option("test")
    set_showmenu("true")
    set_description("The test config option")
option_end()

-- 如果自定义的test配置值是hello1或者hello2
if is_config("test", "hello1", "hello2") then
    add_defines("HELLO")
end
```

不仅如此，我们还可以设置模式匹配规则去判断值，例如：

```lua
-- 如果自定义的test配置值带有hello前缀
if is_config("test", "hello.*") then
    add_defines("HELLO")
end
```

<p class="tips">
此接口不仅能够判断通过[option](#option)定义的自定义配置选项，同时还能判断内置的全局配置、本地配置。
</p>

##### has_config

###### 判断配置是否启用或者存在

此接口从2.2.2版本开始引入，用于检测自定义或者内置的编译配置是否存在或启用，可用于描述域。

例如以下配置情况，都会返回true:

```console
# 启用某个配置选项（如果是boolean类型配置）
$ xmake f --test1=y
$ xmake f --test1=yes
$ xmake f --test1=true

# 设置某个配置选项的值
$ xmake f --test2=value
```

```lua
-- 如果test1或者test2被设置或者启用
if has_config("test1", "test2") then
    add_defines("TEST")
end
```

而下面的情况则会禁用配置，返回false：

```console
# 禁用配置（如果是boolean类型配置）
$ xmake f --test1=n
$ xmake f --test1=no
$ xmake f --test1=false
```

<p class="tips">
此接口不仅能够判断内置的全局配置、本地配置，同时还可以判断通过[option](#option)定义的自定义配置选项。
</p>


##### has_package

###### 判断依赖包是否启用或者存在

此接口从2.2.3版本开始引入，用于检测远程依赖包是否存在或启用，可用于描述域。

一般配合[add_requires](#add_requires)一起使用，例如：

```lua
add_requires("tbox", {optional = true})

target("test")
    set_kind("binary")
    add_files("src/*.c")
    add_packages("tbox")

    if has_package("tbox") then
        add_defines("HAVE_TBOX")
    end
```

如果通过`add_requires`添加的可选依赖包，远程下载安装失败，或者当前平台不支持导致实际上没有被正常安装上，那么`has_package`就会返回false，
表示不存在，然后对其他flags定义甚至源文件编译控制做一些特殊处理。

<p class="tips">
此接口跟[has_config](#has_config)的区别在于，[has_config](#has_config)用于[option](#option)，而它用于[add_requires](#add_requires)。
</p>

#### 全局接口

全局接口影响整个工程描述，被调用后，后面被包含进来的所有子`xmake.lua`都会受影响。

| 接口                                  | 描述                          | 支持版本 |
| ------------------------------------- | ----------------------------- | -------- |
| [includes](#includes)                 | 添加子工程文件和目录          | >= 2.1.5 |
| [set_modes](#set_modes)               | 设置支持的编译模式            | >= 2.1.2 |
| [set_project](#set_project)           | 设置工程名                    | >= 2.0.1 |
| [set_version](#set_version)           | 设置工程版本                  | >= 2.0.1 |
| [set_xmakever](#set_xmakever)         | 设置最小xmake版本             | >= 2.1.1 |
| [add_subdirs](#add_subdirs)           | 添加子工程目录                | >= 1.0.1 |
| [add_subfiles](#add_subfiles)         | 添加子工程文件                | >= 1.0.1 |
| [add_moduledirs](#add_moduledirs)     | 添加模块目录                  | >= 2.1.5 |
| [add_plugindirs](#add_plugindirs)     | 添加插件目录                  | >= 2.0.1 | 
| [add_packagedirs](#add_packagedirs)   | 添加包目录                    | >= 2.0.1 |
| [get_config](#get_config)             | 获取给的配置值                | >= 2.2.2 |
| [set_config](#set_config)             | 设置默认的配置值              | >= 2.2.2 |
| [add_requires](#add_requires)         | 添加需要的依赖包              | >= 2.2.2 |
| [add_repositories](#add_repositories) | 添加依赖包仓库                | >= 2.2.2 |

##### includes

###### 添加子工程文件和目录

同时支持子工程文件和目录的添加，用于替代[add_subdirs](#add_subdirs)和[add_subfiles](#add_subfiles)接口。

另外，此接口在2.2.5之后的版本，提供了一些内置的辅助函数，可以直接includes后使用，具体有哪些内置函数可以看下：https://github.com/xmake-io/xmake/tree/master/xmake/includes

关于这块的更加完整的说明，可以看下：[https://github.com/xmake-io/xmake/issues/342](https://github.com/xmake-io/xmake/issues/342)

##### set_modes

###### 设置支持的编译模式

这个是可选接口，一般情况下不需要设置，目前仅用于对工程增加更加细致的描述信息，方便vs工程的多模式生成，以及其他xmake插件中获取模式信息。

例如：

```lua
set_modes("debug", "release")
```

如果设置了这个，xmake就知道当前工程支持哪些编译模式，这样生成vs工程文件的时候，只需要：

```bash
$ xmake project -k vs2017
```

不再需要额外手动指定需要的编译模式了，此外其他一些想要获取工程信息的插件，也许也会需要这些设置信息。

<p class="tip">
当然，对于[is_mode](#is_mode)接口，`set_modes`不是必须的，就算不设置，也是可以通过`is_mode`正常判断当前的编译模式。
</p>

##### set_project

###### 设置工程名

设置工程名，在doxygen自动文档生成插件、工程文件生成插件中会用到，一般设置在xmake.lua的最开头，当然放在其他地方也是可以的

```lua
-- 设置工程名
set_project("tbox")

-- 设置工程版本
set_version("1.5.1")
```

##### set_version

###### 设置工程版本

设置项目版本，可以放在xmake.lua任何地方，一般放在最开头，例如：

```lua
set_version("1.5.1")
```

以tbox为例，如果调用[set_config_header](#targetset_config_header)设置了`config.h`，那么会自动生成如下宏：

```c
// version
#define TB_CONFIG_VERSION "1.5.1"
#define TB_CONFIG_VERSION_MAJOR 1
#define TB_CONFIG_VERSION_MINOR 5
#define TB_CONFIG_VERSION_ALTER 1
#define TB_CONFIG_VERSION_BUILD 201510220917
```

2.1.7版本支持buildversion的配置：

```lua
set_version("1.5.1", {build = "%Y%m%d%H%M"})
```

##### set_xmakever

###### 设置最小xmake版本

用于处理xmake版本兼容性问题，如果项目的`xmake.lua`，通过这个接口设置了最小xmake版本支持，那么用户环境装的xmake低于要求的版本，就会提示错误。

一般情况下，建议默认对其进行设置，这样对用户比较友好，如果`xmake.lua`中用到了高版本的api接口，用户那边至少可以知道是否因为版本不对导致的构建失败。

设置如下：

```lua
-- 设置最小版本为：2.1.0，低于此版本的xmake编译此工程将会提示版本错误信息
set_xmakever("2.1.0")
```

##### add_subdirs

###### 添加子工程目录

<p class="tips">
xmake 2.x以上版本，请尽量使用[includes](#includes)这个接口，这个是add_subdirs和add_subfiles的通用版本，并且支持一些内建扩展模块。
</p>

每个子工程对应一个`xmake.lua`的工程描述文件。

虽然一个`xmake.lua`也可以描述多个子工程模块，但是如果工程越来越大，越来越复杂，适当的模块化是很有必要的。。

这就需要`add_subdirs`了，将每个子模块放到不同目录中，并为其建立一个新的`xmake.lua`独立去维护它，例如：

```
./tbox
├── src
│   ├── demo
│   │   └── xmake.lua (用来描述测试模块)
│   └── tbox
│       └── xmake.lua（用来描述libtbox库模块）
└── xmake.lua（用该描述通用配置信息，以及对子模块的维护）
````

在`tbox/xmake.lua`中通过`add_subdirs`将拥有`xmale.lua`的子模块的目录，添加进来，就可以了，例如：

```lua
-- 添加libtbox库模块目录
add_subdirs("src/tbox") 

-- 如果xmake f --demo=y，启用了demo模块，那么包含demo目录
if is_option("demo") then 
    add_subdirs("src/demo") 
end
```

默认情况下，xmake会去编译在所有xmake.lua中描述的所有target目标，如果只想编译指定目标，可以执行：

```bash
# 仅仅编译tbox库模块
$ xmake build tbox
```

需要注意的是，每个子`xmake.lua`中所有的路径设置都是相对于当前这个子`xmake.lua`所在的目录的，都是相对路径，这样方便维护

##### add_subfiles

###### 添加子工程文件

<p class="tips">
xmake 2.x以上版本，请尽量使用[includes](#includes)这个接口，这个是add_subdirs和add_subfiles的通用版本，并且支持一些内建扩展模块。
</p>

`add_subfiles`的作用与[add_subdirs](#add_subdirs)类似，唯一的区别就是：这个接口直接指定`xmake.lua`文件所在的路径，而不是目录，例如：

```lua
add_subfiles("src/tbox/xmake.lua")
```

##### add_moduledirs

###### 添加模块目录

xmake内置的扩展模块都在`xmake/modules`目录下，可通过[import](#import)来导入他们，如果自己在工程里面实现了一些扩展模块，
可以放置在这个接口指定的目录下，import也就会能找到，并且优先进行导入。

例如定义一个`find_openssl.lua`的扩展模块，用于扩展内置的[lib.detect.find_package](#detect-find_package)接口，则只需要将它放置在：

```
projectdir/xmake/modules/detect/packages/find_openssl.lua
```

然后在工程`xmake.lua`下指定这个模块目录，`find_package`就可以自动找到了：

```lua
add_moduledirs("projectdir/xmake/modules")
```

##### add_plugindirs

###### 添加插件目录

xmake内置的插件都是放在`xmake/plugins`目录下，但是对于用户自定义的一些特定工程的插件，如果不想放置在xmake安装目录下，那么可以在`xmake.lua`中进行配置指定的其他插件路径。

```lua
-- 将当前工程下的plugins目录设置为自定义插件目录
add_plugindirs("$(projectdir)/plugins")
```

这样，xmake在编译此工程的时候，也就加载这些插件。

##### add_packagedirs

###### 添加包目录

通过设置依赖包目录，可以方便的集成一些第三方的依赖库，以tbox工程为例，其依赖包如下：

```
- base.pkg
- zlib.pkg
- polarssl.pkg
- openssl.pkg
- mysql.pkg
- pcre.pkg
- ...
```

如果要让当前工程识别加载这些包，首先要指定包目录路径，例如：

```lua
add_packagedirs("packages")
```

指定好后，就可以在target作用域中，通过[add_packages](#add_packages)接口，来添加集成包依赖了，例如：

```lua
target("tbox")
    add_packages("zlib", "polarssl", "pcre", "mysql")
```

##### get_config

###### 获取给定的配置值

此接口从2.2.2版本开始引入，用于快速获取给定的配置值，可用于描述域。

```lua
if get_config("myconfig") == "xxx" then
    add_defines("HELLO")
end
```

##### set_config

###### 设置给定的默认配置值

此接口从2.2.2版本开始引入，用于快速在xmake.lua中设置一个默认配置值，仅用于描述域。

之前很多配置，包括编译工具链，构建目录等只能通过`$ xmake f --name=value`的方式来配置，如果我们想写死在xmake.lua提供一个默认值，就可以通过下面的方式来配置：

```lua
set_config("name", "value")
set_config("buildir", "other/buildir")
set_config("cc", "gcc")
set_config("ld", "g++")
```

不过，我们还是可以通过`$ xmake f --name=value`的方式，去修改xmake.lua中的默认配置。

##### add_requires

###### 添加需要的依赖包

xmake的依赖包管理是完全支持语义版本选择的，例如："~1.6.1"，对于语义版本的具体描述见：[https://semver.org/](https://semver.org/)

一些语义版本写法：

```lua
add_requires("tbox 1.6.*", "pcre 1.3.x", "libpng ^1.18")
add_requires("libpng ~1.16", "zlib 1.1.2 || >=1.2.11 <1.3.0")
```

目前xmake使用的语义版本解析器是[uael](https://github.com/uael)贡献的[sv](https://github.com/uael/sv)库，里面也有对版本描述写法的详细说明，可以参考下：[版本描述说明](https://github.com/uael/sv#versions)

当然，如果我们对当前的依赖包的版本没有特殊要求，那么可以直接这么写：

```lua
add_requires("tbox", "libpng", "zlib")
```

这会使用已知的最新版本包，或者是master分支的源码编译的包，如果当前包有git repo地址，我们也能指定特定分支版本：

```lua
add_requires("tbox master")
add_requires("tbox dev")
```

如果指定的依赖包当前平台不支持，或者编译安装失败了，那么xmake会编译报错，这对于有些必须要依赖某些包才能工作的项目，这是合理的。
但是如果有些包是可选的依赖，即使没有也可以正常编译使用的话，可以设置为可选包：

```lua
add_requires("tbox", {optional = true})
```

默认的设置，xmake会去优先检测系统库是否存在（如果没设置版本要求），如果用户完全不想使用系统库以及第三方包管理提供的库，那么可以设置：

```lua
add_requires("tbox", {system = false})
```

如果我们想同时源码调试依赖包，那么可以设置为使用debug版本的包（当然前提是这个包支持debug编译）：

```lua
add_requires("tbox", {debug = true})
```

如果当前包还不支持debug编译，可在仓库中提交修改编译规则，对debug进行支持，例如：

```lua
package("openssl")
    on_install("linux", "macosx", function (package)
        os.vrun("./config %s --prefix=\"%s\"", package:debug() and "--debug" or "", package:installdir())
        os.vrun("make -j4")
        os.vrun("make install")
    end)
```

某些包在编译时候有各种编译选项，我们也可以传递进来，当然包本身得支持：

```lua
add_requires("tbox", {config = {small=true}})
```

传递`--small=true`给tbox包，使得编译安装的tbox包是启用此选项的。

v2.2.3之后，可以通过[option](#option)和[has_config](#has_config)配合，在自己定义配置选项参数中控制是否需要添加某个依赖包：

```lua
option("luajit")
    set_default(false)
    set_showmenu(true)
    set_category("option")
    set_description("Enable the luajit runtime engine.")
option_end()

if has_config("luajit") then
    add_requires("luajit")
else
    add_requires("lua")
end
```

我们可以通过`$xmake f --luajit=y`去切换依赖包。

并且我们也新增了group参数，来分组依赖包，同一个组下的所有依赖包，只能有一个生效启用，启用顺序依赖`add_requires`添加的顺序:

```lua
add_requires("openssl", {group = "ssl", optional = true})
add_requires("mbedtls", {group = "ssl", optional = true})

target("test")
    add_packages("openssl", "mbedtls")
```

例如上面，所以同时依赖两个ssl包，实际上只会启用生效实际安装成功的那一个ssl包，并不会同时链接两个依赖包。

2.2.5版本之后，xmake支持对对第三方包管理器里面的依赖库安装支持，例如：conan，brew, vcpkg等

添加homebrew的依赖包：

```lua
add_requires("brew::zlib", {alias = "zlib"}})
add_requires("brew::pcre2/libpcre2-8", {alias = "pcre2"}})

target("test")
    set_kind("binary")
    add_files("src/*.c") 
    add_packages("pcre2", "zlib")
```

添加vcpkg的依赖包：

```lua
add_requires("vcpkg::zlib", "vcpkg::pcre2")

target("test")
    set_kind("binary")
    add_files("src/*.c") 
    add_packages("vcpkg::zlib", "vcpkg::pcre2")
```

添加conan的依赖包：

```lua
add_requires("CONAN::zlib/1.2.11@conan/stable", {alias = "zlib", debug = true})
add_requires("CONAN::OpenSSL/1.0.2n@conan/stable", {alias = "openssl", 
    configs = {options = "OpenSSL:shared=True"}})

target("test")
    set_kind("binary")
    add_files("src/*.c") 
    add_packages("openssl", "zlib")
```

执行xmake进行编译后：

```console
ruki:test_package ruki$ xmake
checking for the architecture ... x86_64
checking for the Xcode directory ... /Applications/Xcode.app
checking for the SDK version of Xcode ... 10.14
note: try installing these packages (pass -y to skip confirm)?
  -> CONAN::zlib/1.2.11@conan/stable  (debug)
  -> CONAN::OpenSSL/1.0.2n@conan/stable  
please input: y (y/n)

  => installing CONAN::zlib/1.2.11@conan/stable .. ok
  => installing CONAN::OpenSSL/1.0.2n@conan/stable .. ok

[  0%]: ccache compiling.release src/main.c
[100%]: linking.release test
```

关于这块的更多详情见：https://github.com/xmake-io/xmake/issues/339

添加clib的依赖包：

clib是一款基于源码的依赖包管理器，拉取的依赖包是直接下载对应的库源码，集成到项目中编译，而不是二进制库依赖。

其在xmake中集成也很方便，唯一需要注意的是，还需要自己添加上对应库的源码到xmake.lua，例如：

```lua
add_requires("clib::clibs/bytes@0.0.4", {alias = "bytes"})

target("xmake-test")
    set_kind("binary")
    add_files("clib/bytes/*.c")
    add_files("src/*.c") 
    add_packages("bytes")
```

##### add_repositories

###### 添加依赖包仓库

如果需要的包不在官方仓库[xmake-repo](https://github.com/xmake-io/xmake-repo)中，我们可以提交贡献代码到仓库进行支持。
但如果有些包仅用于个人或者私有项目，我们可以建立一个私有仓库repo，仓库组织结构可参考：[xmake-repo](https://github.com/xmake-io/xmake-repo)

比如，现在我们有一个一个私有仓库repo：`git@github.com:myrepo/xmake-repo.git`

我们可以通过此接口来添加：

```lua
add_repositories("my-repo git@github.com:myrepo/xmake-repo.git")
```

如果我们只是想添加一两个私有包，这个时候特定去建立一个git repo太小题大做了，我们可以直接把包仓库放置项目里面，例如：

```
projectdir
  - myrepo
    - packages
      - t/tbox/xmake.lua
      - z/zlib/xmake.lua
  - src
    - main.c
  - xmake.lua
```

上面myrepo目录就是自己的私有包仓库，内置在自己的项目里面，然后在xmake.lua里面添加一下这个仓库位置：

```lua
add_repositories("my-repo myrepo")
```

这个可以参考[benchbox](https://github.com/tboox/benchbox)项目，里面就内置了一个私有仓库。

#### 工程目标

定义和设置子工程模块，每个`target`对应一个子工程，最后会生成一个目标程序，有可能是可执行程序，也有可能是库模块。

<p class="tip">
target的接口，都是可以放置在target外面的全局作用域中的，如果在全局中设置，那么会影响所有子工程target。
</p>

例如：

```lua
-- 会同时影响test和test2目标
add_defines("DEBUG")

target("test")
    add_files("*.c")

target("test2")
    add_files("*.c")
```

<p class="tip">
`target`域是可以重复进入来实现分离设置的。
</p>


| 接口                                            | 描述                                 | 支持版本 |
| ---------------------------------------------   | ------------------------------------ | -------- |
| [target](#target)                               | 定义工程目标                         | >= 1.0.1 |
| [target_end](#target_end)                       | 结束定义工程目标                     | >= 2.1.1 |
| [set_kind](#targetset_kind)                     | 设置目标编译类型                     | >= 1.0.1 |
| [set_strip](#targetset_strip)                   | 设置是否strip信息                    | >= 1.0.1 |
| [set_enabled](#targetset_enabled)               | 设置是否启用或禁用目标               | >= 2.2.2 |
| [set_default](#targetset_default)               | 设置是否为默认构建安装目标           | >= 2.1.3 |
| [set_options](#targetset_options)               | 设置关联选项                         | >= 1.0.1 |
| [set_symbols](#targetset_symbols)               | 设置符号信息                         | >= 1.0.1 |
| [set_basename](#targetset_basename)             | 设置目标文件名                       | >= 2.1.2 |
| [set_filename](#targetset_filename)             | 设置目标文件全名                     | >= 2.1.2 |
| [set_warnings](#targetset_warnings)             | 设置警告级别                         | >= 1.0.1 |
| [set_optimize](#targetset_optimize)             | 设置优化级别                         | >= 1.0.1 |
| [set_languages](#targetset_languages)           | 设置代码语言标准                     | >= 1.0.1 |
| [set_headerdir](#targetset_headerdir)           | 设置头文件安装目录                   | >= 1.0.1 < 2.2.5 已废弃 |
| [set_targetdir](#targetset_targetdir)           | 设置生成目标文件目录                 | >= 1.0.1 |
| [set_objectdir](#targetset_objectdir)           | 设置对象文件生成目录                 | >= 1.0.1 |
| [set_dependir](#targetset_dependir)             | 设置依赖文件生成目录                 | >= 2.2.2 |
| [add_imports](#targetadd_imports)               | 为所有自定义脚本预先导入扩展模块     | >= 2.1.7 |
| [add_rules](#targetadd_rules)                   | 添加规则到目标                       | >= 2.1.9 |
| [on_load](#targeton_load)                       | 自定义目标加载脚本                   | >= 2.1.5 |
| [on_link](#targeton_link)                       | 自定义链接脚本                       | >= 2.2.7 |
| [on_build](#targeton_build)                     | 自定义编译脚本                       | >= 2.0.1 |
| [on_build_file](#targeton_build_file)           | 自定义编译脚本, 实现单文件构建       | >= 2.2.3 |
| [on_build_files](#targeton_build_files)         | 自定义编译脚本, 实现多文件构建       | >= 2.2.3 |
| [on_clean](#targeton_clean)                     | 自定义清理脚本                       | >= 2.0.1 |
| [on_package](#targeton_package)                 | 自定义打包脚本                       | >= 2.0.1 |
| [on_install](#targeton_install)                 | 自定义安装脚本                       | >= 2.0.1 |
| [on_uninstall](#targeton_uninstall)             | 自定义卸载脚本                       | >= 2.0.1 |
| [on_run](#targeton_run)                         | 自定义运行脚本                       | >= 2.0.1 |
| [before_link](#targetbefore_link)               | 在链接之前执行一些自定义脚本         | >= 2.2.7 |
| [before_build](#targetbefore_build)             | 在构建之前执行一些自定义脚本         | >= 2.0.1 |
| [before_build_file](#targetbefore_build_file)   | 自定义编译前的脚本, 实现单文件构建   | >= 2.2.3 |
| [before_build_files](#targetbefore_build_files) | 自定义编译前的脚本, 实现多文件构建   | >= 2.2.3 |
| [before_clean](#targetbefore_clean)             | 在清除之前执行一些自定义脚本         | >= 2.0.1 |
| [before_package](#targetbefore_package)         | 在打包之前执行一些自定义脚本         | >= 2.0.1 |
| [before_install](#targetbefore_install)         | 在安装之前执行一些自定义脚本         | >= 2.0.1 |
| [before_uninstall](#targetbefore_uninstall)     | 在卸载之前执行一些自定义脚本         | >= 2.0.1 |
| [before_run](#targetbefore_run)                 | 在运行之前执行一些自定义脚本         | >= 2.0.1 |
| [after_link](#targetafter_link)                 | 在链接之后执行一些自定义脚本         | >= 2.2.7 |
| [after_build](#targetafter_build)               | 在构建之后执行一些自定义脚本         | >= 2.0.1 |
| [after_build_file](#targetafter_build_file)     | 自定义编译后的脚本, 实现单文件构建   | >= 2.2.3 |
| [after_build_files](#targetafter_build_files)   | 自定义编译后的脚本, 实现多文件构建   | >= 2.2.3 |
| [after_clean](#targetafter_clean)               | 在清除之后执行一些自定义脚本         | >= 2.0.1 |
| [after_package](#targetafter_package)           | 在打包之后执行一些自定义脚本         | >= 2.0.1 |
| [after_install](#targetafter_install)           | 在安装之后执行一些自定义脚本         | >= 2.0.1 |
| [after_uninstall](#targetafter_uninstall)       | 在卸载之后执行一些自定义脚本         | >= 2.0.1 |
| [after_run](#targetafter_run)                   | 在运行之后执行一些自定义脚本         | >= 2.0.1 |
| [set_config_h](#targetset_config_h)             | 设置自动生成的配置头文件路径         | >= 1.0.1 < 2.1.5 已废弃 |
| [set_config_h_prefix](#targetset_config_h)      | 设置自动生成的头文件中宏定义命名前缀 | >= 1.0.1 < 2.1.5 已废弃 |
| [set_config_header](#targetset_config_header)   | 设置自动生成的配置头文件路径和前缀   | >= 2.1.5 < 2.2.5 已废弃 |
| [set_pcheader](#targetset_pcheader)             | 设置c预编译头文件                    | >= 2.1.5 |
| [set_pcxxheader](#targetset_pcxxheader)         | 设置c++预编译头文件                  | >= 2.1.5 |
| [add_deps](#targetadd_deps)                     | 添加子工程目标依赖                   | >= 1.0.1 |
| [add_links](#targetadd_links)                   | 添加链接库名                         | >= 1.0.1 |
| [add_syslinks](#targetadd_syslinks)             | 添加系统链接库名                     | >= 2.2.3 |
| [add_files](#targetadd_files)                   | 添加源代码文件                       | >= 1.0.1 |
| [del_files](#targetdel_files)                   | 从前面的源文件列表中删除指定文件     | >= 2.1.9 |
| [add_headers](#targetadd_headers)               | 添加安装的头文件                     | >= 1.0.1 < 2.2.5 已废弃 |
| [add_linkdirs](#targetadd_linkdirs)             | 添加链接库搜索目录                   | >= 1.0.1 |
| [add_rpathdirs](#targetadd_rpathdirs)           | 添加运行时候动态链接库搜索目录       | >= 2.1.3 |
| [add_includedirs](#targetadd_includedirs)       | 添加头文件搜索目录                   | >= 1.0.1 |
| [add_defines](#targetadd_defines)               | 添加宏定义                           | >= 1.0.1 |
| [add_undefines](#targetadd_undefines)           | 取消宏定义                           | >= 1.0.1 |
| [add_defines_h](#targetadd_defines_h)           | 添加宏定义到头文件                   | >= 1.0.1 |
| [add_undefines_h](#targetadd_undefines_h)       | 取消宏定义到头文件                   | >= 1.0.1 |
| [add_cflags](#targetadd_cflags)                 | 添加c编译选项                        | >= 1.0.1 |
| [add_cxflags](#targetadd_cxflags)               | 添加c/c++编译选项                    | >= 1.0.1 |
| [add_cxxflags](#targetadd_cxxflags)             | 添加c++编译选项                      | >= 1.0.1 |
| [add_mflags](#targetadd_mflags)                 | 添加objc编译选项                     | >= 1.0.1 |
| [add_mxflags](#targetadd_mxflags)               | 添加objc/objc++编译选项              | >= 1.0.1 |
| [add_mxxflags](#targetadd_mxxflags)             | 添加objc++编译选项                   | >= 1.0.1 |
| [add_scflags](#targetadd_scflags)               | 添加swift编译选项                    | >= 2.0.1 |
| [add_asflags](#targetadd_asflags)               | 添加汇编编译选项                     | >= 2.0.1 |
| [add_gcflags](#targetadd_gcflags)               | 添加go编译选项                       | >= 2.1.1 |
| [add_dcflags](#targetadd_dcflags)               | 添加dlang编译选项                    | >= 2.1.1 |
| [add_rcflags](#targetadd_rcflags)               | 添加rust编译选项                     | >= 2.1.1 |
| [add_cuflags](#targetadd_cuflags)               | 添加cuda编译选项                     | >= 2.2.1 |
| [add_culdflags](#targetadd_culdflags)           | 添加cuda设备链接选项                 | >= 2.2.7 |
| [add_ldflags](#targetadd_ldflags)               | 添加链接选项                         | >= 1.0.1 |
| [add_arflags](#targetadd_arflags)               | 添加静态库归档选项                   | >= 1.0.1 |
| [add_shflags](#targetadd_shflags)               | 添加动态库链接选项                   | >= 1.0.1 |
| [add_cfunc](#targetadd_cfunc)                   | 添加单个c库函数检测                  | >= 2.0.1 |
| [add_cxxfunc](#targetadd_cxxfunc)               | 添加单个c++库函数检测                | >= 2.0.1 |
| [add_cfuncs](#targetadd_cfuncs)                 | 添加c库函数检测                      | >= 2.0.1 |
| [add_cxxfuncs](#targetadd_cxxfuncs)             | 添加c++库函数接口                    | >= 2.0.1 |
| [add_packages](#targetadd_packages)             | 添加包依赖                           | >= 2.0.1 |
| [add_options](#targetadd_options)               | 添加关联选项                         | >= 2.0.1 |
| [add_languages](#targetadd_languages)           | 添加语言标准                         | >= 1.0.1 |
| [add_vectorexts](#targetadd_vectorexts)         | 添加向量扩展指令                     | >= 1.0.1 |
| [add_frameworks](#targetadd_frameworks)         | 添加链接框架                         | >= 2.1.1 |
| [add_frameworkdirs](#targetadd_frameworkdirs)   | 添加链接框架的搜索目录               | >= 2.1.5 |
| [set_tools](#targetset_tools)                   | 设置编译链接工具链                   | >= 2.2.1 |
| [add_tools](#targetadd_tools)                   | 添加编译链接工具链                   | >= 2.2.1 |
| [set_values](#targetset_values)                 | 设置一些扩展配置值                   | >= 2.2.1 |
| [add_values](#targetadd_values)                 | 添加一些扩展配置值                   | >= 2.2.1 |
| [set_rundir](#targetset_rundir)                 | 设置运行目录                         | >= 2.2.7 |
| [add_runenvs](#targetadd_runenvs)               | 添加运行环境变量                     | >= 2.2.7 |
| [set_installdir](#targetset_installdir)         | 设置安装目录                         | >= 2.2.5 |
| [add_installfiles](#targetadd_installfiles)     | 添加安装文件                         | >= 2.2.5 |
| [add_headerfiles](#targetadd_headerfiles)       | 添加安装头文件                       | >= 2.2.5 |
| [set_configdir](#targetset_configdir)           | 设置模板配置文件输出目录             | >= 2.2.5 |
| [set_configvar](#targetset_configvar)           | 设置模板配置变量                     | >= 2.2.5 |
| [add_configfiles](#targetadd_configfiles)       | 添加模板配置文件                     | >= 2.2.5 |

##### target

###### 定义工程目标

定义一个新的控制台工程目标，工程名为`test`，最后生成的目标名也是`test`。

```lua
target("test")
    set_kind("binary")
    add_files("src/*.c")
```

可以重复调用这个api，进入target域修改设置

```lua
-- 定义目标demo，并进入demo设置模式
target("demo")
    set_kind("binary")
    add_files("src/demo.c")

-- 定义和设置其他目标
target("other")
    ...

-- 重新进入demo目标域，添加test.c文件
target("demo")
    add_files("src/test.c")
```

<p class="tip">
所有根域的设置，会全局影响所有target目标，但是不会影响option的定义。
</p>

```lua
-- 在根域对所有target添加-DDEBUG的宏定义，影响所有target（demo和test都会加上此宏定义）
add_defines("DEBUG")

target("demo")
    set_kind("binary")
    add_files("src/demo.c")

target("test")
    set_kind("binary")
    add_files("src/test.c")
```

##### target_end

###### 结束定义工程目标

这是一个可选的api，如果不调用，那么`target("xxx")`之后的所有设置都是针对这个target进行的，除非进入其他`target`, `option`, `task`域。

如果想设置完当前`target`后，显示离开`target`域，进入根域设置，那么可以通过这个api才操作，例如：

```lua
target("test")
    set_kind("static")
    add_files("src/*.c")
target_end()

-- 此处已在根域
-- ...
```

如果不调用这个api的话:

```lua
target("test")
    set_kind("static")
    add_files("src/*.c")

-- 此处还在上面target域中，之后的设置还是针对test进行的设置
-- ...

-- 这个时候才离开test，进入另外一个target域中
target("test2")
    ...
```

##### target:set_kind

###### 设置目标编译类型

设置目标类型，目前支持的类型有：

| 值     | 描述       |
| ------ | -----------|
| binary | 二进制程序 |
| static | 静态库程序 |
| shared | 动态库程序 |

```lua
target("demo")
    set_kind("binary")
```

##### target:set_strip

###### 设置是否strip信息

设置当前目标的strip模式，目前支持一下模式：

| 值     | 描述                                      |
| ------ | ----------------------------------------- |
| debug  | 链接的时候，strip掉调试符号               |
| all    | 链接的时候，strip掉所有符号，包括调试符号 |

这个api一般在release模式下使用，可以生成更小的二进制程序。。

```lua
target("xxxx")
    set_strip("all")
```

<p class="tip">
这个api不一定非得在target之后使用，如果没有target指定，那么将会设置到全局模式。。
</p>

##### target:set_enabled

###### 设置是否启用或禁用目标

如果设置`set_enabled(false)`，则会直接禁用对应的target，包括target的加载和信息获取，而[set_default](#targetset_default)仅仅只是设置默认不去编译，但是target还是能获取到相关信息的，默认也会被加载。

##### target:set_default

###### 设置是否为默认构建安装目标

这个接口用于设置给定工程目标是否作为默认构建，如果没有调用此接口进行设置，那么这个目标就是默认被构建的，例如：

```lua
target("test1")
    set_default(false)

target("test2")
    set_default(true)

target("test3")
    ...
```

上述代码的三个目标，在执行`xmake`, `xmake install`, `xmake package`, `xmake run`等命令的时候，如果不指定目标名，那么：

| 目标名 | 行为                             |
| ------ | -------------------------------- |
| test1  | 不会被默认构建、安装、打包和运行 |
| test2  | 默认构建、安装、打包和运行       |
| test3  | 默认构建、安装、打包和运行       |

通过上面的例子，可以看到默认目标可以设置多个，运行的时候也会依次运行。

<p class="tip">
    需要注意的是，`xmake uninstall`和`xmake clean`命令不受此接口设置影响，因为用户大部分情况下都是喜欢清除和卸载所有。
</p>

如果不想使用默认的目标，那么可以手动指定需要构建安装的目标：

```bash
$ xmake build targetname
$ xmake install targetname
```

如果要强制构建安装所有目标，可以传入`[-a|--all]`参数：

```bash
$ xmake build [-a|--all]
$ xmake install [-a|--all]
```

##### target:set_options

###### 设置关联选项

添加选项依赖，如果通过[option](#option)接口自定义了一些选项，那么只有在指定`target`目标域下，添加此选项，才能进行关联生效。

```lua
-- 定义一个hello选项
option("hello")
    set_default(false)
    set_showmenu(true)
    add_defines("HELLO_ENABLE")

target("test")
    -- 如果hello选项被启用了，这个时候就会将-DHELLO_ENABLE宏应用到test目标上去
    set_options("hello")
```

<p class="warning">
只有调用`set_options`进行关联生效后，[option](#option) 中定义的一些设置才会影响到此`target`目标，例如：宏定义、链接库、编译选项等等
</p>

##### target:set_symbols

###### 设置符号信息

设置目标的符号模式，如果当前没有定义target，那么将会设置到全局状态中，影响所有后续的目标。

目前主要支持一下几个级别：

| 值     | 描述                   |
| ------ | ---------------------- |
| debug  | 添加调试符号           |
| hidden | 设置符号不可见         |

这两个值也可以同时被设置，例如：

```lua
-- 添加调试符号, 设置符号不可见
set_symbols("debug", "hidden")
```

如果没有调用这个api，默认是禁用调试符号的。。

##### target:set_basename

###### 设置目标文件名

默认情况下，生成的目标文件名基于`target("name")`中配置的值，例如：

```lua
-- 目标文件名为：libxxx.a
target("xxx")
    set_kind("static")

-- 目标文件名为：libxxx2.so
target("xxx2")
    set_kind("shared")
```

默认的命名方式，基本上可以满足大部分情况下的需求，但是如果有时候想要更加定制化目标文件名

例如，按编译模式和架构区分目标名，这个时候可以使用这个接口，来设置：

```lua
target("xxx")
    set_kind("static")
    set_basename("xxx_$(mode)_$(arch)")
```

如果这个时候，编译配置为：`xmake f -m debug -a armv7`，那么生成的文件名为：`libxxx_debug_armv7.a`

如果还想进一步定制目标文件的目录名，可参考：[set_targetdir](#targetset_targetdir)。

或者通过编写自定义脚本，实现更高级的逻辑，具体见：[after_build](#targetafter_build)和[os.mv](#os-mv)。

##### target:set_filename

###### 设置目标文件全名

它跟[set_basename](#targetset_basename)的区别在于，[set_basename](#targetset_basename)设置名字不带后缀跟前缀，例如：`libtest.a`，basename如果改成test2后就变成了`libtest2.a`。

而filename的修改，是修改整个目标文件名，包括前后缀，例如可以直接把`libtest.a`改成`test.dll`，这个对于[set_basename](#targetset_basename)是做不到的。

##### target:set_warnings

###### 设置警告级别

设置当前目标的编译的警告级别，一般支持一下几个级别：

| 值    | 描述                   | gcc/clang  | msvc                          |
| ----- | ---------------------- | ---------- | ----------------------------- |
| none  | 禁用所有警告           | -w         | -W0                           |
| less  | 启用较少的警告         | -W1        | -W1                           |
| more  | 启用较多的警告         | -W3        | -W3                           |
| all   | 启用所有警告           | -Wall      | -W3 (-Wall too more warnings) |
| everything | 启用全部支持的警告 | -Wall -Wextra -Weffc++ / -Weverything | -Wall |
| error | 将所有警告作为编译错误 | -Werror    | -WX                           |

这个api的参数是可以混合添加的，例如：

```lua
-- 启用所有警告，并且作为编译错误处理
set_warnings("all", "error")
```

如果当前没有目标，调用这个api将会设置到全局模式。。

##### target:set_optimize

###### 设置优化级别

设置目标的编译优化等级，如果当前没有设置目标，那么将会设置到全局状态中，影响所有后续的目标。

目前主要支持一下几个级别：

| 值         | 描述                   | gcc/clang  | msvc         |
| ---------- | ---------------------- | ---------- | ------------ |
| none       | 禁用优化               | -O0        | -Od          |
| fast       | 快速优化               | -O1        | default      |
| faster     | 更快的优化             | -O2        | -Ox          |
| fastest    | 最快运行速度的优化     | -O3        | -Ox -fp:fast |
| smallest   | 最小化代码优化         | -Os        | -O1          |
| aggressive | 过度优化               | -Ofast     | -Ox -fp:fast |


例如：

```lua
-- 最快运行速度的优化
set_optimize("fastest")
```

##### target:set_languages

###### 设置代码语言标准

设置目标代码编译的语言标准，如果当前没有目标存在，将会设置到全局模式中。。。

支持的语言标准目前主要有以下几个：

| 值         | 描述                   |
| ---------- | ---------------------- |
| ansi       | c语言标准: ansi        |
| c89        | c语言标准: c89         |
| gnu89      | c语言标准: gnu89       |
| c99        | c语言标准: c99         |
| gnu99      | c语言标准: gnu99       |
| cxx98      | c++语言标准: `c++98`   |
| gnuxx98    | c++语言标准: `gnu++98` |
| cxx11      | c++语言标准: `c++11`   |
| gnuxx11    | c++语言标准: `gnu++11` |
| cxx14      | c++语言标准: `c++14`   |
| gnuxx14    | c++语言标准: `gnu++14` |
| cxx1z      | c++语言标准: `c++1z`   |
| gnuxx1z    | c++语言标准: `gnu++1z` |
| cxx17      | c++语言标准: `c++17`   |
| gnuxx17    | c++语言标准: `gnu++17` |

c标准和c++标准可同时进行设置，例如：

```lua
-- 设置c代码标准：c99， c++代码标准：c++11
set_languages("c99", "cxx11")
```

<p class="warning">
并不是设置了指定的标准，编译器就一定会按这个标准来编译，毕竟每个编译器支持的力度不一样，但是xmake会尽最大可能的去适配当前编译工具的支持标准。。。
<br><br>
例如：
<br>
windows下vs的编译器并不支持按c99的标准来编译c代码，只能支持到c89，但是xmake为了尽可能的支持它，所以在设置c99的标准后，xmake会强制按c++代码模式去编译c代码，从一定程度上解决了windows下编译c99的c代码问题。。
用户不需要去额外做任何修改。。
</p>

##### target:set_headerdir

###### 设置头文件安装目录

<p class="warning">
注，2.2.5版本之后，此接口已废弃，请使用[add_headerfiles](#targetadd_headerfiles)代替。
</p>

设置头文件的输出目录，默认输出到build目录中。

```lua
target("test")
    set_headerdir("$(buildir)/include")
```

对于需要安装哪些头文件，可参考[add_headers](#targetadd_headers)接口。

##### target:set_targetdir

###### 设置生成目标文件目录

设置目标程序文件的输出目录，一般情况下，不需要设置，默认会输出在build目录下

而build的目录可以在工程配置的时候，手动修改：

```bash
xmake f -o /tmp/build
```

修改成`/tmp/build`后，目标文件默认输出到`/tmp/build`下面。

而如果用这个接口去设置，就不需要每次敲命令修改了，例如：

```lua
target("test")
    set_targetdir("/tmp/build")
```

<p class="tip">
如果显示设置了`set_targetdir`， 那么优先选择`set_targetdir`指定的目录为目标文件的输出目录。
</p>

##### target:set_objectdir

###### 设置对象文件生成目录

设置目标target的对象文件(`*.o/obj`)的输出目录，例如:

```lua
target("test")
    set_objectdir("$(buildir)/.objs")
```

##### target:set_dependir

###### 设置依赖文件生成目录

设置目标target的编译依赖文件(`.deps`)的输出目录，例如:

```lua
target("test")
    set_dependir("$(buildir)/.deps")
```

##### target:add_imports

###### 为自定义脚本预先导入扩展模块

通常，我们在[on_build](#targeton_build)等自定义脚本内部，可以通过`import("core.base.task")`的方式导入扩展模块，
但是对于自定义脚本比较多的情况下，每个自定义脚本都重复导入一遍，非常的繁琐，那么可以通过这个接口，实现预先导入，例如：

```lua
target("test")
    on_load(function (target)
        import("core.base.task")
        import("core.project.project")

        task.run("xxxx")
    end)
    on_build(function (target)
        import("core.base.task")
        import("core.project.project")
        
        task.run("xxxx")
    end)
    on_install(function (target)
        import("core.base.task")
        import("core.project.project")
        
        task.run("xxxx")
    end)
```

通过此接口可以简化为：

```lua
target("test")
    add_imports("core.base.task", "core.project.project")
    on_load(function (target)
        task.run("xxxx")
    end)
    on_build(function (target)
        task.run("xxxx")
    end)
    on_install(function (target)
        task.run("xxxx")
    end)
```

##### target:add_rules

###### 添加规则到目标

我们可以通过预先设置规则支持的文件后缀，来扩展其他文件的构建支持：

```lua
-- 定义一个markdown文件的构建规则
rule("markdown")
    set_extensions(".md", ".markdown")
    on_build(function (target, sourcefile)
        os.cp(sourcefile, path.join(target:targetdir(), path.basename(sourcefile) .. ".html"))
    end)

target("test")
    set_kind("binary")
    
    -- 使test目标支持markdown文件的构建规则
    add_rules("markdown")

    -- 添加markdown文件的构建
    add_files("src/*.md")
    add_files("src/*.markdown")
```

我们也可以指定应用局部文件到规则，具体使用见：[add_files](#targetadd_files)。

##### target:on_load

###### 自定义目标加载脚本

在target初始化加载的时候，将会执行此脚本，在里面可以做一些动态的目标配置，实现更灵活的目标描述定义，例如：

```lua
target("test")
    on_load(function (target)
        target:add("defines", "DEBUG", "TEST=\"hello\"")
        target:add("linkdirs", "/usr/lib", "/usr/local/lib")
        target:add({includedirs = "/usr/include", "links" = "pthread"})
    end)
```

可以在`on_load`里面，通过`target:set`, `target:add` 来动态添加各种target属性。

##### target:on_link

###### 自定义链接脚本

这个是在v2.2.7之后新加的接口，用于定制化处理target的链接过程。

```lua
target("test")
    on_link(function (target) 
        print("link it")
    end)
```

##### target:on_build

###### 自定义编译脚本

覆盖target目标默认的构建行为，实现自定义的编译过程，一般情况下，并不需要这么做，除非确实需要做一些xmake默认没有提供的编译操作。

你可以通过下面的方式覆盖它，来自定义编译操作：

```lua
target("test")

    -- 设置自定义编译脚本
    on_build(function (target) 
        print("build it")
    end)
```

注：2.1.5版本之后，所有target的自定义脚本都可以针对不同平台和架构，分别处理，例如：

```lua
target("test")
    on_build("iphoneos|arm*", function (target)
        print("build for iphoneos and arm")
    end)
```

其中如果第一个参数为字符串，那么就是指定这个脚本需要在哪个`平台|架构`下，才会被执行，并且支持模式匹配，例如`arm*`匹配所有arm架构。

当然也可以只设置平台，不设置架构，这样就是匹配指定平台下，执行脚本：

```lua
target("test")
    on_build("windows", function (target)
        print("build for windows")
    end)
```

<p class="tip">
一旦对这个target目标设置了自己的build过程，那么xmake默认的构建过程将不再被执行。
</p>


##### target:on_build_file

###### 自定义编译脚本, 实现单文件构建

通过此接口，可以用来hook指定target内置的构建过程，替换每个源文件编译过程：

```lua
target("test")
    set_kind("binary")
    add_files("src/*.c")
    on_build_file(function (target, sourcefile, opt)
        opt.origin(target, sourcefile, opt)
    end)
```

上面代码中的`opt.origin`存有内置的构建脚本，如果hook后还是想调用内置的构建脚本去编译源文件，那么直接继续调用`opt.origin`就行了。

如果不想重写内置的编译脚本，仅仅只是在编译前后添加一些自己的处理，其实用：[target.before_build_file](#targetbefore_build_file)和[target.after_build_file](#targetafter_build_file)会更加方便，不需要调用`opt.origin`。

##### target:on_build_files

###### 自定义编译脚本, 实现多文件构建

通过此接口，可以用来hook指定target内置的构建过程，替换一批同类型源文件编译过程：

```lua
target("test")
    set_kind("binary")
    add_files("src/*.c")
    on_build_files(function (target, sourcebatch, opt)
        opt.origin(target, sourcebatch, opt)
    end)
```

设置此接口后，对应源文件列表中文件，就不会出现在自定义的[target.on_build_file](#targeton_build_file)了，因为这个是包含关系。

其中sourcebatch描述了这批同类型源文件：

* `sourcebatch.sourcekind`: 获取这批源文件的类型，比如：cc, as, ..
* `sourcebatch.sourcefiles()`: 获取源文件列表
* `sourcebatch.objectfiles()`: 获取对象文件列表
* `sourcebatch.dependfiles()`: 获取对应依赖文件列表，存有源文件中编译依赖信息，例如：xxx.d

上面代码中的`opt.origin`存有内置的构建脚本，如果hook后还是想调用内置的构建脚本去编译源文件，那么直接继续调用`opt.origin`就行了。

##### target:on_clean

###### 自定义清理脚本

覆盖target目标的`xmake [c|clean}`的清理操作，实现自定义清理过程。

```lua
target("test")

    -- 设置自定义清理脚本
    on_clean(function (target) 

        -- 仅删掉目标文件
        os.rm(target:targetfile())
    end)
```

一些target接口描述如下：

| target接口                          | 描述                                                             |
| ----------------------------------- | ---------------------------------------------------------------- |
| target:name()                       | 获取目标名                                                       |
| target:targetfile()                 | 获取目标文件路径                                                 |
| target:get("kind")                  | 获取目标的构建类型                                               |
| target:get("defines")               | 获取目标的宏定义                                                 |
| target:get("xxx")                   | 其他通过 `set_/add_`接口设置的target信息，都可以通过此接口来获取 |
| target:add("links", "pthread")      | 添加目标设置                                                     |
| target:set("links", "pthread", "z") | 覆写目标设置                                                     |
| target:deps()                       | 获取目标的所有依赖目标                                           |
| target:dep("depname")               | 获取指定的依赖目标                                               |
| target:sourcebatches()              | 获取目标的所有源文件列表                                         |

##### target:on_package

###### 自定义打包脚本

覆盖target目标的`xmake [p|package}`的打包操作，实现自定义打包过程，如果你想对指定target打包成自己想要的格式，可以通过这个接口自定义它。

这个接口还是挺实用的，例如，编译完jni后，将生成的so，打包进apk包中。

```lua
-- 定义一个android app的测试demo
target("demo")

    -- 生成动态库：libdemo.so
    set_kind("shared")

    -- 设置对象的输出目录，可选
    set_objectdir("$(buildir)/.objs")

    -- 每次编译完的libdemo.so的生成目录，设置为app/libs/armeabi
    set_targetdir("libs/armeabi")

    -- 添加jni的代码文件
    add_files("jni/*.c")

    -- 设置自定义打包脚本，在使用xmake编译完libdemo.so后，执行xmake p进行打包
    -- 会自动使用ant将app编译成apk文件
    --
    on_package(function (target) 

        -- 使用ant编译app成apk文件，输出信息重定向到日志文件
        os.run("ant debug") 
    end)
```

##### target:on_install

###### 自定义安装脚本

覆盖target目标的`xmake [i|install}`的安装操作，实现自定义安装过程。

例如，将生成的apk包，进行安装。

```lua
target("test")

    -- 设置自定义安装脚本，自动安装apk文件
    on_install(function (target) 

        -- 使用adb安装打包生成的apk文件
        os.run("adb install -r ./bin/Demo-debug.apk")
    end)
```

##### target:on_uninstall

###### 自定义卸载脚本

覆盖target目标的`xmake [u|uninstall}`的卸载操作，实现自定义卸载过程。

```lua
target("test")
    on_uninstall(function (target) 
        ...
    end)
```

##### target:on_run

###### 自定义运行脚本

覆盖target目标的`xmake [r|run}`的运行操作，实现自定义运行过程。

例如，运行安装好的apk程序：

```lua
target("test")

    -- 设置自定义运行脚本，自动运行安装好的app程序，并且自动获取设备输出信息
    on_run(function (target) 

        os.run("adb shell am start -n com.demo/com.demo.DemoTest")
        os.run("adb logcat")
    end)
```

##### target:before_link

###### 在链接之前执行一些自定义脚本

这个是在v2.2.7之后新加的接口，用于在链接之前增加一些自定义的操作。

```lua
target("test")
    before_link(function (target) 
        print("")
    end)
```

##### target:before_build

###### 在构建之前执行一些自定义脚本

并不会覆盖默认的构建操作，只是在构建之前增加一些自定义的操作。

```lua
target("test")
    before_build(function (target)
        print("")
    end)
```

##### target:before_build_file

###### 自定义编译前的脚本, 实现单文件构建 

通过此接口，可以用来hook指定target内置的构建过程，在每个源文件编译过程之前执行一些自定义脚本：

```lua
target("test")
    set_kind("binary")
    add_files("src/*.c")
    before_build_file(function (target, sourcefile, opt)
    end)
```

##### target:before_build_files

###### 自定义编译前的脚本, 实现多文件构建 

通过此接口，可以用来hook指定target内置的构建过程，在一批同类型源文件编译过程之前执行一些自定义脚本：

```lua
target("test")
    set_kind("binary")
    add_files("src/*.c")
    before_build_files(function (target, sourcebatch, opt)
    end)
```

##### target:before_clean

###### 在清理之前执行一些自定义脚本

并不会覆盖默认的清理操作，只是在清理之前增加一些自定义的操作。

```lua
target("test")
    before_clean(function (target)
        print("")
    end)
```

##### target:before_package

###### 在打包之前执行一些自定义脚本

并不会覆盖默认的打包操作，只是在打包之前增加一些自定义的操作。

```lua
target("test")
    before_package(function (target)
        print("")
    end)
```

##### target:before_install

###### 在安装之前执行一些自定义脚本

并不会覆盖默认的安装操作，只是在安装之前增加一些自定义的操作。

```lua
target("test")
    before_install(function (target)
        print("")
    end)
```

##### target:before_uninstall

###### 在卸载之前执行一些自定义脚本

并不会覆盖默认的卸载操作，只是在卸载之前增加一些自定义的操作。

```lua
target("test")
    before_uninstall(function (target)
        print("")
    end)
```

##### target:before_run

###### 在运行之前执行一些自定义脚本

并不会覆盖默认的运行操作，只是在运行之前增加一些自定义的操作。

```lua
target("test")
    before_run(function (target)
        print("")
    end)
```

##### target:after_link

###### 在链接之后执行一些自定义脚本

这个是在v2.2.7之后新加的接口，用于在链接之后增加一些自定义的操作。

```lua
target("test")
    after_link(function (target) 
        print("")
    end)
```

##### target:after_build

###### 在构建之后执行一些自定义脚本

并不会覆盖默认的构建操作，只是在构建之后增加一些自定义的操作。

例如，对于ios的越狱开发，构建完程序后，需要用`ldid`进行签名操作

```lua
target("test")
    after_build(function (target)
        os.run("ldid -S %s", target:targetfile())
    end)
```

##### target:after_build_file

###### 自定义编译前的脚本, 实现单文件构建 

通过此接口，可以用来hook指定target内置的构建过程，在每个源文件编译过程之后执行一些自定义脚本：

```lua
target("test")
    set_kind("binary")
    add_files("src/*.c")
    after_build_file(function (target, sourcefile, opt)
    end)
```

##### target:after_build_files

###### 自定义编译前的脚本, 实现多文件构建 

通过此接口，可以用来hook指定target内置的构建过程，在一批同类型源文件编译过程之后执行一些自定义脚本：

```lua
target("test")
    set_kind("binary")
    add_files("src/*.c")
    after_build_files(function (target, sourcebatch, opt)
    end)
```

##### target:after_clean

###### 在清理之后执行一些自定义脚本

并不会覆盖默认的清理操作，只是在清理之后增加一些自定义的操作。

一般可用于清理编译某target自动生成的一些额外的临时文件，这些文件xmake默认的清理规则可能没有清理到，例如：

```lua
target("test")
    after_clean(function (target)
        os.rm("$(buildir)/otherfiles")
    end)
```

##### target:after_package

###### 在打包之后执行一些自定义脚本

并不会覆盖默认的打包操作，只是在打包之后增加一些自定义的操作。

```lua
target("test")
    after_package(function (target)
        print("")
    end)
```

##### target:after_install

###### 在安装之后执行一些自定义脚本

并不会覆盖默认的安装操作，只是在安装之后增加一些自定义的操作。

```lua
target("test")
    after_install(function (target)
        print("")
    end)
```
##### target:after_uninstall

###### 在卸载之后执行一些自定义脚本

并不会覆盖默认的卸载操作，只是在卸载之后增加一些自定义的操作。

```lua
target("test")
    after_uninstall(function (target)
        print("")
    end)
```

##### target:after_run

###### 在运行之后执行一些自定义脚本

并不会覆盖默认的运行操作，只是在运行之后增加一些自定义的操作。

```lua
target("test")
    after_run(function (target)
        print("")
    end)
```

##### target:set_config_h

###### 设置自动生成的配置头文件路径

<p class="warning">
2.2.5版本之后，此接口已废弃，请使用[add_configfiles](#targetadd_configfiles)。
2.1.5版本之后，此接口已废弃，请使用[set_config_header](#targetset_config_header)。
</p>

如果你想在xmake配置项目成功后，或者自动检测某个选项通过后，把检测的结果写入配置头文件，那么需要调用这个接口来启用自动生成`config.h`文件。

使用方式例如：

```lua
target("test")

    -- 启用并设置需要自动生成的config.h文件路径
    set_config_h("$(buildir)/config.h")

    -- 设置自动检测生成的宏开关的名字前缀
    set_config_h_prefix("TB_CONFIG")
```

当这个target中通过下面的这些接口，对这个target添加了相关的选项依赖、包依赖、接口依赖后，如果某依赖被启用，那么对应的一些宏定义配置，会自动写入被设置的`config.h`文件中去。

* [add_options](#targetadd_options)
* [add_packages](#targetadd_packages)
* [add_cfuncs](#targetadd_cfuncs)
* [add_cxxfuncs](#targetadd_cxxfuncs) 

这些接口，其实底层都用到了[option](#option)选项中的一些检测设置，例如：

```lua
option("wchar")

    -- 添加对wchar_t类型的检测
    add_ctypes("wchar_t")

    -- 如果检测通过，自动生成 TB_CONFIG_TYPE_HAVE_WCHAR的宏开关到config.h
    add_defines_h("$(prefix)_TYPE_HAVE_WCHAR")

target("test")

    -- 启用头文件自动生成
    set_config_h("$(buildir)/config.h")
    set_config_h_prefix("TB_CONFIG")

    -- 添加对wchar选项的依赖关联，只有加上这个关联，wchar选项的检测结果才会写入指定的config.h中去
    add_options("wchar")
```

##### target:set_config_h_prefix

###### 设置自动生成的头文件中宏定义命名前缀

<p class="warning">
2.2.5版本之后，此接口已废弃，请使用[add_configfiles](#targetadd_configfiles)。
2.1.5版本之后，此接口已废弃，请使用[set_config_header](#targetset_config_header)。
</p>

具体使用见：[set_config_h](#targetset_config_h)

如果设置了：

```lua
target("test")
    set_config_h_prefix("TB_CONFIG")
```

那么，选项中`add_defines_h("$(prefix)_TYPE_HAVE_WCHAR")`的$(prefix)会自动被替换成新的前缀值。

##### target:set_config_header

###### 设置自动生成的配置头文件路径和前缀

<p class="warning">
2.2.5版本之后，此接口已废弃，请使用[add_configfiles](#targetadd_configfiles)。
</p>

此接口是[set_config_h](#targetset_config_h)和[set_config_h_prefix](#targetset_config_h_prefix)的升级版本，2.1.5之后支持。

如果你想在xmake配置项目成功后，或者自动检测某个选项通过后，把检测的结果写入配置头文件，那么需要调用这个接口来启用自动生成`config.h`文件。

使用方式例如：

```lua
target("test")
    set_config_header("$(buildir)/config.h", {prefix = "TB_CONFIG"})
```

上面的代码，启用并设置需要自动生成的config.h文件路径，并且设置自动检测生成的宏开关的名字前缀：`TB_CONFIG`, 当然这个前缀的设置是可选的。

```lua
target("test")
    set_config_header("$(buildir)/config.h")
```

如果不设置前缀，将会自动根据target名生成一个唯一字串。

2.1.8 之后版本，支持针对每个局部配置文件，单独设置版本号，优先于全局的[set_version](#set_version)，例如：

```lua
    set_config_header("$(buildir)/config.h", {prefix = "TB_CONFIG", version = "2.1.8", build = "%Y%m%d%H%M"})
```

###### 通过内置的检测规则生成配置

当这个target中通过下面的这些接口，对这个target添加了相关的选项依赖、包依赖、接口依赖后，如果某依赖被启用，那么对应的一些宏定义配置，会自动写入被设置的`config.h`文件中去。

* [add_options](#targetadd_options)
* [add_packages](#targetadd_packages)
* [add_cfunc](#targetadd_cfunc)
* [add_cfuncs](#targetadd_cfuncs)
* [add_cxxfuncs](#targetadd_cxxfuncs) 

###### 定制化检测和生成配置头文件

这些接口，其实底层都用到了[option](#option)选项中的一些检测设置，例如：

```lua
option("wchar")

    -- 添加对wchar_t类型的检测
    add_ctypes("wchar_t")

    -- 如果检测通过，自动生成 TB_CONFIG_TYPE_HAVE_WCHAR的宏开关到config.h
    add_defines_h("$(prefix)_TYPE_HAVE_WCHAR")

target("test")

    -- 启用头文件自动生成
    set_config_header("$(buildir)/config.h", {prefix = "TB_CONFIG"})

    -- 添加对wchar选项的依赖关联，只有加上这个关联，wchar选项的检测结果才会写入指定的config.h中去
    add_options("wchar")
```

甚至我们可以在`xmake.lua`中自己定义个function，针对option进行封装，提供更加定制化的检测和生成config.h的过程

例如：这里有个需求，我们想批量检测一些头文件，如果存在则在config.h里面输出`HAVE_LIMITS_H`这样的宏开关，我们可以这么写

```lua
function add_checking_to_config(...)

    -- 批量定义option检测规则，仅检测include文件
    local options = {}
    for _, header in ipairs({...}) do 
        local define = header:upper():gsub("[%./]", "_")
        option(define)
            add_cincludes(header)
            add_defines_h("HAVE_" .. define) -- 生成 HAVE_LIMITS_H 这样的宏开关到config.h 
        option_end()
        table.insert(options, define)
    end

    -- 定义个内置__config空目标，仅用于关联设置automatedconfig.h，以及对应的options检测规则
    -- 因为set_config_header在全局设置，会影响所有target，对每个target都会检测生成一次宏开关
    target("__config")
        set_kind("phony")
        set_config_header("includes/automatedconfig.h")
        add_options(options)
    target_end()
end

-- 添加一些头文件检测
add_checking_to_config("arpa/inet.h", "limits.h", "fcntl.h", "xxxx.h")
```

##### target:set_pcheader

###### 设置c预编译头文件

xmake支持通过预编译头文件去加速c程序编译，目前支持的编译器有：gcc, clang和msvc。

使用方式如下：

```lua
target("test")
    set_pcheader("header.h")
```

##### target:set_pcxxheader

###### 设置c++预编译头文件

xmake支持通过预编译头文件去加速c++程序编译，目前支持的编译器有：gcc, clang和msvc。

使用方式如下：

```lua
target("test")
    set_pcxxheader("header.h")
```

##### target:add_deps

###### 添加子工程目标依赖

添加当前目标的依赖目标，编译的时候，会去优先编译依赖的目标，然后再编译当前目标。。。

```lua
target("test1")
    set_kind("static")
    set_files("*.c")

target("test2")
    set_kind("static")
    set_files("*.c")

target("demo")
    add_deps("test1", "test2")
```

上面的例子，在编译目标demo的时候，需要先编译test1, test2目标，因为demo会去用到他们

<p class="tip">
target会自动继承依赖目标中的配置和属性，不需要额外调用`add_links`, `add_linkdirs`和`add_rpathdirs`等接口去关联依赖目标了。
</p>

并且继承关系是支持级联的，例如：

```lua
target("library1")
    set_kind("static")
    add_files("*.c")
    add_includedirs("inc") -- 默认私有头文件目录不会被继承
    add_includedirs("inc1", {public = true}) -- 此处的头文件相关目录也会被继承

target("library2")
    set_kind("static")
    add_deps("library1")
    add_files("*.c")

target("test")
    set_kind("binary")
    add_deps("library2")
```

如果我们不想继承依赖target的任何配置，如何操作呢？

```lua
add_deps("dep1", "dep2", {inherit = false})
```

通过显式设置inherit配置，来告诉xmake，这两个依赖的配置是否需要被继承，如果不设置，默认就是启用继承的。

2.2.5版本之后，可通过 `add_includedirs("inc1", {public = true})`, 设置public为true, 将includedirs的设置公开给其他依赖的子target继承。 

目前对于target的编译链接flags相关接口设置，都是支持继承属性的，可以人为控制是否需要导出给其他target来依赖继承，目前支持的属性有：

| 属性      | 描述                                                             |
| ----      | ----                                                             |
| private   | 默认设置，作为当前target的私有配置，不会被依赖的其他target所继承 |
| public    | 公有配置，当前target，依赖的子target都会被设置                   |
| interface | 接口设置，仅被依赖的子target所继承设置，当前target不参与         |

对于这块的详细说明，可以看下：https://github.com/xmake-io/xmake/issues/368

##### target:add_links

###### 添加链接库名

为当前目标添加链接库，一般这个要与[add_linkdirs](#targetadd_linkdirs)配对使用。

```lua
target("demo")

    -- 添加对libtest.a的链接，相当于 -ltest 
    add_links("test")

    -- 添加链接搜索目录
    add_linkdirs("$(buildir)/lib")
```

##### target:add_syslinks

###### 添加系统链接库名

这个接口使用上跟[add_links](#targetadd_links)类似，唯一的区别就是，通过这个接口添加的链接库顺序在所有`add_links`之后。

因此主要用于添加系统库依赖，因为系统库的链接顺序是非常靠后的，例如：

```lua
add_syslinks("pthread", "m", "dl")
target("demo")
    add_links("a", "b")
    add_linkdirs("$(buildir)/lib")
```

上面的配置，即使`add_syslinks`被优先提前设置了，但最后的链接顺序依然是：`-la -lb -lpthread -lm -ldl`

##### target:add_files

###### 添加源代码文件

用于添加目标工程的源文件，甚至库文件，目前支持的一些文件类型：

| 支持的源文件类型   | 描述                               |
| ------------------ | ---------------------------------- |
| .c/.cpp/.cc/.cxx   | c++文件                            |
| .s/.S/.asm         | 汇编文件                           |
| .m/.mm             | objc文件                           |
| .swift             | swift文件                          |
| .go                | golang文件                         |
| .o/.obj            | 对象文件                           |
| .a/.lib            | 静态库文件，会自动合并库到目标程序 |
| .rc                | msvc的资源文件                     |

其中通配符`*`表示匹配当前目录下文件，而`**`则匹配多级目录下的文件。

例如：

```lua
add_files("src/test_*.c")
add_files("src/xxx/**.cpp")
add_files("src/asm/*.S", "src/objc/**/hello.m")
```

`add_files`的使用其实是相当灵活方便的，其匹配模式借鉴了premake的风格，但是又对其进行了改善和增强。

使得不仅可以匹配文件，还有可以在添加文件同时，过滤排除指定模式的一批文件。

例如：

```lua
-- 递归添加src下的所有c文件，但是不包括src/impl/下的所有c文件
add_files("src/**.c|impl/*.c")

-- 添加src下的所有cpp文件，但是不包括src/test.cpp、src/hello.cpp以及src下所有带xx_前缀的cpp文件
add_files("src/*.cpp|test.cpp|hello.cpp|xx_*.cpp")
```

其中分隔符`|`之后的都是需要排除的文件，这些文件也同样支持匹配模式，并且可以同时添加多个过滤模式，只要中间用`|`分割就行了。。

添加文件的时候支持过滤一些文件的一个好处就是，可以为后续根据不同开关逻辑添加文件提供基础。

<p class="tip">
为了使得描述上更加的精简，`|`之后的过滤描述都是基于起一个模式：`src/*.cpp` 中`*`之前的目录为基础的。
所以上面的例子后面过滤的都是在src下的文件，这个是要注意的。
</p>

2.1.6版本之后，对`add_files`进行了改进，支持基于files更细粒度的编译选项控制，例如：

```lua
target("test")
    add_defines("TEST1")
    add_files("src/*.c")
    add_files("test/*.c", "test2/test2.c", {defines = "TEST2", languages = "c99", includedirs = ".", cflags = "-O0"})
```

可以在`add_files`的最后一个参数，传入一个配置table，去控制指定files的编译选项，里面的配置参数跟target的一致，并且这些文件还会继承target的通用配置`-DTEST1`。

2.1.9版本之后，支持添加未知的代码文件，通过设置rule自定义规则，实现这些文件的自定义构建，例如：

```lua
target("test")
    -- ...
    add_files("src/test/*.md", {rule = "markdown"})
```

关于自定义构建规则的使用说明，详细见：[构建规则](#构建规则)。

并且在2.1.9版本之后，可以通过force参数来强制禁用cxflags,cflags等编译选项的自动检测，直接传入编译器，哪怕编译器有可能不支持，也会设置：

```lua
add_files("src/*.c", {force = {cxflags = "-DTEST", mflags = "-framework xxx"}})
```

##### target:del_files

###### 从前面的源代码文件列表中删除指定文件

通过此接口，可以从前面[add_files](targetadd_files)接口添加的文件列表中，删除指定的文件，例如：

```lua
target("test")
    add_files("src/*.c")
    del_files("src/test.c")
```

上面的例子，可以从`src`目录下添加除`test.c`以外的所有文件，当然这个也可以通过`add_files("src/*.c|test.c")`来达到相同的目的，但是这种方式更加灵活。

例如，我们可以条件判断来控制删除哪些文件，并且此接口也支持[add_files](targetadd_files)的匹配模式，过滤模式，进行批量移除。

```lua
target("test")
    add_files("src/**.c")
    del_files("src/test*.c")
    del_files("src/subdir/*.c|xxx.c")
    if is_plat("iphoneos") then
        add_files("xxx.m")
    end
```

通过上面的例子，我们可以看出`add_files`和`del_files`是根据调用顺序，进行顺序添加和删除的，并且通过`del_files("src/subdir/*.c|xxx.c")`删除一批文件，
并且排除`src/subdir/xxx.c`（就是说，不删除这个文件）。

##### target:add_headers

###### 添加安装的头文件

<p class="warning">
注，2.2.5版本之后，此接口已废弃，请使用[add_headerfiles](#targetadd_headerfiles)代替。
</p>

安装指定的头文件到build目录，如果设置了[set_headerdir](#targetset_headerdir)， 则输出到指定目录。

安装规则的语法跟[add_files](#targetadd_files)类似，例如：

```lua
    -- 安装tbox目录下所有的头文件（忽略impl目录下的文件），并且按()指定部分作为相对路径，进行安装
    add_headers("../(tbox/**.h)|**/impl/**.h")
```

##### target:add_linkdirs

###### 添加链接库搜索目录

设置链接库的搜索目录，这个接口的使用方式如下：

```lua
target("test")
    add_linkdirs("$(buildir)/lib")
```

此接口相当于gcc的`-Lxxx`链接选项。

一般他是与[add_links](#targetadd_links)配合使用的，当然也可以直接通过[add_ldflags](#targetadd_ldflags)或者[add_shflags](#targetadd_shflags)接口来添加，也是可以的。

<p class="tip">
如果不想在工程中写死，可以通过：`xmake f --linkdirs=xxx`或者`xmake f --ldflags="-L/xxx"`的方式来设置，当然这种手动设置的目录搜索优先级更高。
</p>

##### target:add_rpathdirs

###### 添加程序运行时动态库的加载搜索目录

通过[add_linkdirs](#targetadd_linkdirs)设置动态库的链接搜索目录后，程序被正常链接，但是在linux平台想要正常运行编译后的程序，会报加载动态库失败。

因为没找到动态库的加载目录，想要正常运行依赖动态库的程序，需要设置`LD_LIBRARY_PATH`环境变量，指定需要加载的动态库目录。

但是这种方式是全局的，影响太广，更好的方式是通过`-rpath=xxx`的链接器选项，在链接程序的时候设置好需要加载的动态库搜索路径，而xmake对其进行了封装，通过`add_rpathdirs`更好的处理跨平台问题。

具体使用如下：

```lua
target("test")
    set_kind("binary")
    add_linkdirs("$(buildir)/lib")
    add_rpathdirs("$(buildir)/lib")
```

只需要在链接的时候，在设置下rpath目录就好了，虽然也可以通过`add_ldflags("-Wl,-rpath=xxx")`达到相同的目的，但是这个接口更加通用。

内部会对不同平台进行处理，像在macOS下，是不需要`-rpath`设置的，也是可以正常加载运行程序，因此针对这个平台，xmake内部会直接忽略器设置，避免链接报错。

而在为dlang程序进行动态库链接时，xmake会自动处理成`-L-rpath=xxx`来传入dlang的链接器，这样就避免了直接使用`add_ldflags`需要自己判断和处理不同平台和编译器问题。

2.1.7版本对这个接口进行了改进，支持：`@loader_path`, `@executable_path` 和 `$ORIGIN`的内置变量，来指定程序的加载目录，它们的效果基本上是一样的，主要是为了同时兼容macho, elf。

例如：

```lua
target("test")
    set_kind("binary")
    add_linkdirs("$(buildir)/lib")
    add_rpathdirs("@loader_path/lib")
```

指定test程序加载当前执行目录下`lib/*.[so|dylib]`的动态库文件，这将有助于提升程序的可移植性，不用写死绝对路径和相对路径，导致程序和目录切换引起程序加载动态库失败。

<p class="tip">
需要注意的是，在macos下，要想add_rpathdirs设置生效，需要对dylib做一些预处理，添加`@rpath/xxx`路径设置：
`$install_name_tool -add_rpath @rpath/libxxx.dylib xxx/libxxx.dylib`
我们也可以通过`otool -L libxxx.dylib`查看是否存在带@rpath的路径
</p>

##### target:add_includedirs

###### 添加头文件搜索目录

设置头文件的搜索目录，这个接口的使用方式如下：

```lua
target("test")
    add_includedirs("$(buildir)/include")
```

当然也可以直接通过[add_cxflags](#targetadd_cxflags)或者[add_mxflags](#targetadd_mxflags)等接口来设置，也是可以的。

2.2.5之后，可通过额外的`{public|interface = true}`属性设置，将includedirs导出给依赖的子target，例如：

```lua
target("test")
    set_kind("static")
    add_includedirs("src/include") -- 仅对当前target生效
    add_includedirs("$(buildir)/include", {public = true})，当前target和子target都会被设置

target("demo")
    set_kind("binary")
    add_deps("test")
```

更多关于这块的说明，见：[add_deps](#targetadd_deps)

<p class="tip">
如果不想在工程中写死，可以通过：`xmake f --includedirs=xxx`或者`xmake f --cxflags="-I/xxx"`的方式来设置，当然这种手动设置的目录搜索优先级更高。
</p>

##### target:add_defines

###### 添加宏定义

```lua
add_defines("DEBUG", "TEST=0", "TEST2=\"hello\"")
```

相当于设置了编译选项：

```
-DDEBUG -DTEST=0 -DTEST2=\"hello\"
```

##### target:add_undefines

###### 取消宏定义

```lua
add_undefines("DEBUG")
```

相当于设置了编译选项：`-UDEBUG`

在代码中相当于：`#undef DEBUG`

##### target:add_defines_h

###### 添加宏定义到头文件

<p class="warning">
2.2.5版本之后，此接口已废弃，请使用[add_configfiles](#targetadd_configfiles)。
</p>

添加宏定义到`config.h`配置文件，`config.h`的设置，可参考[set_config_h](#targetset_config_h)接口。

##### target:add_undefines_h

###### 取消宏定义到头文件

<p class="warning">
2.2.5版本之后，此接口已废弃，请使用[add_configfiles](#targetadd_configfiles)。
</p>

在`config.h`配置文件中通过`undef`禁用宏定义，`config.h`的设置，可参考[set_config_h](#targetset_config_h)接口。

##### target:add_cflags

###### 添加c编译选项 

仅对c代码添加编译选项

```lua
add_cflags("-g", "-O2", "-DDEBUG")
```

<p class="warning">
所有选项值都基于gcc的定义为标准，如果其他编译器不兼容（例如：vc），xmake会自动内部将其转换成对应编译器支持的选项值。
用户无需操心其兼容性，如果其他编译器没有对应的匹配值，那么xmake会自动忽略器设置。
</p>


在2.1.9版本之后，可以通过force参数来强制禁用flags的自动检测，直接传入编译器，哪怕编译器有可能不支持，也会设置：

```lua
add_cflags("-g", "-O2", {force = true})
```

##### target:add_cxflags

###### 添加c/c++编译选项

同时对c/c++代码添加编译选项

##### target:add_cxxflags

###### 添加c++编译选项

仅对c++代码添加编译选项

##### target:add_mflags

###### 添加objc编译选项 

仅对objc代码添加编译选项

```lua
add_mflags("-g", "-O2", "-DDEBUG")
```

在2.1.9版本之后，可以通过force参数来强制禁用flags的自动检测，直接传入编译器，哪怕编译器有可能不支持，也会设置：

```lua
add_mflags("-g", "-O2", {force = true})
```

##### target:add_mxflags

###### 添加objc/objc++编译选项

同时对objc/objc++代码添加编译选项

```lua
add_mxflags("-framework CoreFoundation")
```

##### target:add_mxxflags

###### 添加objc++编译选项

仅对objc++代码添加编译选项

```lua
add_mxxflags("-framework CoreFoundation")
```

##### target:add_scflags

###### 添加swift编译选项

对swift代码添加编译选项

```lua
add_scflags("xxx")
```

##### target:add_asflags

###### 添加汇编编译选项

对汇编代码添加编译选项

```lua
add_asflags("xxx")
```

##### target:add_gcflags

###### 添加go编译选项

对golang代码添加编译选项

```lua
add_gcflags("xxx")
```

##### target:add_dcflags

###### 添加dlang编译选项

对dlang代码添加编译选项

```lua
add_dcflags("xxx")
```

##### target:add_rcflags

###### 添加rust编译选项

对rust代码添加编译选项

```lua
add_rcflags("xxx")
```

##### target:add_cuflags

###### 添加cuda编译选项

对cuda代码添加编译选项

```lua
add_cuflags("-gencode arch=compute_30,code=sm_30")
```

##### target:add_culdflags

###### 添加cuda设备链接选项

v2.2.7之后，cuda默认构建会使用device-link，这个阶段如果要设置一些链接flags，则可以通过这个接口来设置。
而最终的程序链接，会使用ldflags，不会调用nvcc，直接通过gcc/clang等c/c++链接器来链接。

关于device-link的说明，可以参考：https://devblogs.nvidia.com/separate-compilation-linking-cuda-device-code/

```lua
add_culdflags("-gencode arch=compute_30,code=sm_30")
```

##### target:add_ldflags

###### 添加链接选项

添加静态链接选项

```lua
add_ldflags("-L/xxx", "-lxxx")
```

##### target:add_arflags

###### 添加静态库归档选项

影响对静态库的生成

```lua
add_arflags("xxx")
```
##### target:add_shflags

###### 添加动态库链接选项

影响对动态库的生成

```lua
add_shflags("xxx")
```

##### target:add_cfunc

###### 添加单个c库函数检测

与[add_cfuncs](#targetadd_cfuncs)类似，只是仅对单个函数接口进行设置，并且仅对`target`域生效，`option`中不存在此接口。

此接口的目的主要是为了在`config.h`中更加高度定制化的生成宏开关，例如：

```lua
target("demo")
    
    -- 设置和启用config.h
    set_config_header("$(buildir)/config.h", {prefix = "TEST"})

    -- 仅通过参数一设置模块名前缀
    add_cfunc("libc",       nil,        nil,        {"sys/select.h"},   "select")

    -- 通过参数三，设置同时检测链接库：libpthread.a
    add_cfunc("pthread",    nil,        "pthread",  "pthread.h",        "pthread_create")

    -- 通过参数二设置接口别名
    add_cfunc(nil,          "PTHREAD",  nil,        "pthread.h",        "pthread_create")
```

生成的结果如下：

```c
#ifndef TEST_H
#define TEST_H

// 宏命名规则：$(prefix)前缀 _ 模块名（如果非nil）_ HAVE _ 接口名或者别名 （大写）
#define TEST_LIBC_HAVE_SELECT 1
#define TEST_PTHREAD_HAVE_PTHREAD_CREATE 1
#define TEST_HAVE_PTHREAD 1

#endif
```

如果要更加灵活的函数检测，可以通过[lib.detect.has_cfuncs](#detect-has_cfuncs)在自定义脚本中实现。

##### target:add_cxxfunc

###### 添加单个c++库函数检测

与[add_cfunc](#targetadd_cfunc)类似，只是检测的函数接口是c++函数。

##### target:add_cfuncs

###### 添加c库函数检测

<p class="warning">
此接口是`target`和`option`共用的接口，但是接口行为稍有不同。
</p>

| 接口域 | 描述                                                                      | 例子                                                                                                                             |
| ------ | ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| target | 头文件、链接库和函数接口同时指定                                          | `add_cfuncs("libc", nil, {"signal.h", "setjmp.h"}, "signal", "setjmp", "sigsetjmp{sigjmp_buf buf; sigsetjmp(buf, 0);}", "kill")` |
| option | 仅指定函数接口，头文件依赖[add_cincludes](#targetadd_cincludes)等独立接口 | `add_cincludes("setjmp.h")` `add_cfuncs("sigsetjmp")`                                                                            |

对于`option`，这个接口的使用很简单，跟[add_cincludes](#targetadd_cincludes)类似，例如：

```lua
option("setjmp")
    set_default(false)
    add_cincludes("setjmp.h")
    add_cfuncs("sigsetjmp", "setjmp")
    add_defines("HAVE_SETJMP")

target("test")
    add_options("setjmp")
```

此选项检测是否存在`setjmp`的一些接口，如果检测通过那么`test`目标程序将会加上`HAVE_SETJMP`的宏定义。

<p class="warning">
需要注意的是，在`option`中使用此接口检测依赖函数，需要同时使用独立的[add_cincludes](#targetadd_cincludes)增加头文件搜索路径，指定[add_links](#targetadd_links)链接库（可选），否则检测不到指定函数。
<br><br>
并且某些头文件接口是通过宏开关分别定义的，那么检测的时候最好通过[add_defines](#targetadd_defines)带上依赖的宏开关。
</p>

对于`target`，此接口可以同时设置：依赖的头文件、依赖的链接模块、依赖的函数接口，保证检测环境的完整性，例如：

```lua
target("test")

    -- 添加libc库接口相关检测
    -- 第一个参数：模块名，用于最后的宏定义前缀生成
    -- 第二个参数：链接库
    -- 第三个参数：头文件
    -- 之后的都是函数接口列表
    add_cfuncs("libc", nil,         {"signal.h", "setjmp.h"},           "signal", "setjmp", "sigsetjmp{sigjmp_buf buf; sigsetjmp(buf, 0);}", "kill")

    -- 添加pthread库接口相关检测，同时指定需要检测`libpthread.a`链接库是否存在
    add_cfuncs("posix", "pthread",  "pthread.h",                        "pthread_mutex_init",
                                                                        "pthread_create", 
                                                                        "pthread_setspecific", 
                                                                        "pthread_getspecific",
                                                                        "pthread_key_create",
                                                                        "pthread_key_delete")
```

设置`test`目标，依赖这些接口，构建时会预先检测他们，并且如果通过[set_config_h](#targetset_config_h)接口设置的自动生成头文件：`config.h`

那么，检测结果会自动加到对应的`config.h`上去，这也是`option`没有的功能，例如：

```c
#define TB_CONFIG_LIBC_HAVE_SIGNAL 1
#define TB_CONFIG_LIBC_HAVE_SETJMP 1
#define TB_CONFIG_LIBC_HAVE_SIGSETJMP 1
#define TB_CONFIG_LIBC_HAVE_KILL 1

#define TB_CONFIG_POSIX_HAVE_PTHREAD_MUTEX_INIT 1
#define TB_CONFIG_POSIX_HAVE_PTHREAD_CREATE 1
#define TB_CONFIG_POSIX_HAVE_PTHREAD_SETSPECIFIC 1
#define TB_CONFIG_POSIX_HAVE_PTHREAD_GETSPECIFIC 1
#define TB_CONFIG_POSIX_HAVE_PTHREAD_KEY_CREATE 1
#define TB_CONFIG_POSIX_HAVE_PTHREAD_KEY_DELETE 1
```

由于，不同头文件中，函数的定义方式不完全相同，例如：宏函数、静态内联函数、extern函数等。

要想完全检测成功，检测语法上需要一定程度的灵活性，下面是一些语法规则：

| 检测语法      | 例子                                            |
| ------------- | ----------------------------------------------- |
| 纯函数名      | `sigsetjmp`                                     |
| 单行调用      | `sigsetjmp((void*)0, 0)`                        |
| 函数块调用    | `sigsetjmp{sigsetjmp((void*)0, 0);}`            |
| 函数块 + 变量 | `sigsetjmp{int a = 0; sigsetjmp((void*)a, a);}` |

##### target:add_cxxfuncs

###### 添加c++库函数检测

与[add_cfuncs](#targetadd_cfuncs)类似，只是检测的函数接口是c++函数。

##### target:add_options

###### 添加关联选项

这个接口跟[set_options](#targetset_options)类似，唯一的区别就是，此处是追加选项，而[set_options](#targetset_options)每次设置会覆盖先前的设置。

##### target:add_packages

###### 添加包依赖

在target作用域中，添加集成包依赖，例如：

```lua
target("test")
    add_packages("zlib", "polarssl", "pcre", "mysql")
```

这样，在编译test目标时，如果这个包存在的，将会自动追加包里面的宏定义、头文件搜索路径、链接库目录，也会自动链接包中所有库。

用户不再需要自己单独调用[add_links](#targetadd_links)，[add_includedirs](#targetadd_includedirs), [add_ldflags](#targetadd_ldflags)等接口，来配置依赖库链接了。

对于如何设置包搜索目录，可参考：[add_packagedirs](#targetadd_packagedirs) 接口

而在v2.2.2版本之后，此接口也同时支持远程依赖包管理中[add_requires](#add_requires)定义的包。

```lua
add_requires("zlib", "polarssl")
target("test")
    add_packages("zlib", "polarssl")
```

v2.2.3之后，还支持覆写内置的links，控制实际链接的库：


```lua
-- 默认会有 ncurses, panel, form等links
add_requires("ncurses") 

target("test")
    
    -- 显示指定，只使用ncurses一个链接库
    add_packages("ncurses", {links = "ncurses"})
```

或者干脆禁用links，只使用头文件：

```lua
add_requires("lua")
target("test")
    add_packages("lua", {links = {}})
```

##### target:add_languages

###### 添加语言标准

与[set_languages](#targetset_languages)类似，唯一区别是这个接口不会覆盖掉之前的设置，而是追加设置。

##### target:add_vectorexts

###### 添加向量扩展指令

添加扩展指令优化选项，目前支持以下几种扩展指令集：

```lua
add_vectorexts("mmx")
add_vectorexts("neon")
add_vectorexts("avx", "avx2")
add_vectorexts("sse", "sse2", "sse3", "ssse3")
```

<p class="tip">
如果当前设置的指令集编译器不支持，xmake会自动忽略掉，所以不需要用户手动去判断维护，只需要将你需要的指令集全部设置上就行了。
</p>

##### target:add_frameworks

###### 添加链接框架

目前主要用于`ios`和`macosx`平台的`objc`和`swift`程序，例如：

```lua
target("test")
    add_frameworks("Foundation", "CoreFoundation")
```

当然也可以使用[add_mxflags](#targetadd_mxflags)和[add_ldflags](#targetadd_ldflags)来设置，不过比较繁琐，不建议这样设置。

```lua
target("test")
    add_mxflags("-framework Foundation", "-framework CoreFoundation")
    add_ldflags("-framework Foundation", "-framework CoreFoundation")
```

如果不是这两个平台，这些设置将会被忽略。

##### target:add_frameworkdirs

###### 添加链接框架搜索目录

对于一些第三方framework，那么仅仅通过[add_frameworks](#targetadd_frameworks)是没法找到的，还需要通过这个接口来添加搜索目录。

```lua
target("test")
    add_frameworks("MyFramework")
    add_frameworkdirs("/tmp/frameworkdir", "/tmp/frameworkdir2")
```

##### target:set_tools

###### 设置编译链接工具链

对于`add_files("*.c")`添加的源码文件，默认都是会调用系统最匹配的编译工具去编译，或者通过`xmake f --cc=clang`命令手动去修改，不过这些都是全局影响所有target目标的。

如果有些特殊需求，需要对当前工程下某个特定的target目标单独指定不同的编译器、链接器或者特定版本的编译器，这个时候此接口就可以排上用途了，例如：

```lua
target("test1")
    add_files("*.c")

target("test2")
    add_files("*.c")
    set_tools("cc", "$(projectdir)/tools/bin/clang-5.0")
```

上述描述仅对test2目标的编译器进行特殊设置，使用特定的clang-5.0编译器来编译test2，而test1还是使用默认设置。

对于同时设置多个编译器类型，可以这么写：

```lua
set_tools {
    cc = path.join(os.projectdir(), "tools/bin/clang-5.0"),
    mm = path.join(os.projectdir(), "tools/bin/clang-5.0"),
}
```

<p class="tip">
每次设置都会覆盖当前target目标下之前的那次设置，不同target之间不会被覆盖，互相独立，如果在根域设置，会影响所有子target。
</p>

或者可以使用[add_tools](#targetadd_tools)来设置：

```lua
add_tools("cc", "$(projectdir)/tools/bin/clang-5.0")
add_tools("mm", "$(projectdir)/tools/bin/clang-5.0")
```

前一个参数是key，用于指定工具类型，目前支持的有（编译器、链接器、归档器）：

| 工具类型     | 描述                                 |
| ------------ | ------------------------------------ |
| cc           | c编译器                              |
| cxx          | c++编译器                            |
| mm           | objc编译器                           |
| mxx          | objc++编译器                         |
| gc           | go编译器                             |
| as           | 汇编器                               |
| sc           | swift编译器                          |
| rc           | rust编译器                           |
| dc           | dlang编译器                          |
| ld           | c/c++/asm/objc等通用可执行程序链接器 |
| sh           | c/c++/asm/objc等通用动态库链接器     |
| ar           | c/c++/asm/objc等通用静态库归档器     |
| dc-ld        | dlang可执行链接器, rc-ld/gc-ld等类似 |
| dc-sh        | dlang动态库链接器, rc-sh/gc-sh等类似 |

对于一些编译器文件名不规则，导致xmake无法正常识别处理为已知的编译器名的情况下，我们也可以加一个工具名提示，例如：

```lua
add_tools("cc", "gcc@$(projectdir)/tools/bin/mipscc.exe")
```

上述描述设置mipscc.exe作为c编译器，并且提示xmake作为gcc的传参处理方式进行编译。

##### target:add_tools

###### 添加编译链接工具链

类似[set_tools](#targetset_tools)，区别就是此接口可以多次调用，去添加多个工具，而[set_tools](#targetset_tools)每次设置都会覆盖之前的设置。

##### target:set_values

###### 设置一些扩展配置值

给target设置一些扩展的配置值，这些配置没有像`set_ldflags`这种内置的api可用，通过第一个参数传入一个配置名，来扩展配置。
一般用于传入配置参数给自定义rule中的脚本使用，例如：

```lua
rule("markdown")
    on_build_file(function (target, sourcefile, opt)
        -- compile .markdown with flags
        local flags = target:values("markdown.flags")
        if flags then
            -- ..
        end
    end)

target("test")
    add_files("src/*.md", {rule = "markdown"})
    set_values("markdown.flags", "xxx", "xxx")
```

上述代码例子中，可以看出，在target应用markdown规则的时候，通过set_values去设置一些flags值，提供给markdown规则去处理。
在规则脚本中可以通过`target:values("markdown.flags")`获取到target中设置的扩展flags值。

<p class="tip">
具体扩展配置名，根据不同的rule，会有所不同，目前有哪些，可以参考相关规则的描述：[内建规则](#内建规则)
</p>

##### target:add_values

###### 添加一些扩展配置值

用法跟[target:set_values](#targetset_tools)类似，区别就是这个接口是追加设置，而不会每次覆盖设置。

##### target:set_rundir

###### 设置运行目录

此接口用于设置默认运行target程序的当前运行目录，如果不设置，默认情况下，target是在可执行文件所在目录加载运行。

如果用户想要修改加载目录，一种是通过`on_run()`的方式自定义运行逻辑，里面去做切换，但仅仅为了切个目录就这么做，太过繁琐。

因此可以通过这个接口快速的对默认执行的目录环境做设置切换。

```lua
target("test")
    set_kind("binary")
    add_files("src/*.c")
    set_rundir("$(projectdir)/xxx")
```

##### target:add_runenvs

###### 添加运行环境变量

此接口用于添加设置默认运行target程序的环境变量。

```lua
target("test")
    set_kind("binary")
    add_files("src/*.c")
    add_runenvs("PATH", "/tmp/bin", "xxx/bin")
    add_runenvs("NAME", "value")
```

##### target:set_installdir

###### 设置安装目录

2.2.5版本新增接口，用于针对每个target设置不同的默认安装目录，一般用于`xmake install/uninstall`命令。

默认情况下执行`xmake install`会安装到系统`/usr/local`目录，我们除了可以通过`xmake install -o /usr/local`指定其他安装目录外，
还可以在xmake.lua中针对target设置不同的安装目录来替代默认目录。

除了上述两种方式，我们也可以通过`INSTALLDIR`和`DESTDIR`环境变量设置默认的安装目录。

##### target:add_installfiles

###### 添加安装文件

2.2.5版本新增接口，用于针对每个target设置对应需要安装的文件，一般用于`xmake install/uninstall`命令。

比如我们可以指定安装各种类型的文件到安装目录：

```lua
target("test")
    add_installfiles("src/*.h")
    add_installfiles("doc/*.md")
```

默认在linux等系统上，我们会安装到`/usr/local/*.h, /usr/local/*.md`，不过我们也可以指定安装到特定子目录：

```lua
target("test")
    add_installfiles("src/*.h", {prefixdir = "include"})
    add_installfiles("doc/*.md", {prefixdir = "share/doc"})
```

上面的设置，我们会安装到`/usr/local/include/*.h, /usr/local/share/doc/*.md`

我们也可以通过`()`去提取源文件中的子目录来安装，例如：

```lua
target("test")
    add_installfiles("src/(tbox/*.h)", {prefixdir = "include"})
    add_installfiles("doc/(tbox/*.md)", {prefixdir = "share/doc"})
```

我们把`src/tbox/*.h`中的文件，提取`tbox/*.h`子目录结构后，在进行安装：`/usr/local/include/tbox/*.h, /usr/local/share/doc/tbox/*.md`

当然，用户也可以通过[set_installdir](#targetset_installdir)接口，来配合使用。

关于此接口的详细说明，见：https://github.com/xmake-io/xmake/issues/318

##### target:add_headerfiles

###### 添加安装头文件

2.2.5版本新增接口，用于针对每个target设置对应需要安装的头文件，一般用于`xmake install/uninstall`命令。

此接口使用方式跟[add_installfiles](#targetadd_installfiles)接口几乎完全一样，都可以用来天剑安装文件，不过此接口仅用于安装头文件。
因此，使用上比`add_installfiles`简化了不少，默认不设置prefixdir，也会自动将头文件安装到对应的`include`子目录中。

并且此接口对于`xmake project -k vs201x`等插件生成的IDE文件，也会添加对应的头文件进去。

<p class="tips">
需要注意的是，之前的[add_headers](#targetadd_headers)接口已经被废弃，新版本请用此接口替代，这个老接口在编译过程中也会自动复制头文件到build目录，这个逻辑设计的并不是很好。
</p>

##### target:set_configdir

###### 设置模板配置文件的输出目录

2.2.5版本新增接口，主要用于[add_configfiles](#targetadd_configfiles)接口设置的模板配置文件的输出目录。

##### target:set_configvar

###### 设置模板配置变量

2.2.5版本新增接口，用于在编译前，添加一些需要预处理的模板配置变量，一般用于[add_configfiles](#targetadd_configfiles)接口。

##### target:add_configfiles

###### 添加模板配置文件

2.2.5版本新增接口，用于在编译前，添加一些需要预处理的配置文件，用于替代[set_config_header](#targetset_config_header)等老接口。

因为此接口更加的通用，不仅用于处理config.h的自动生成和预处理，还可以处理各种文件类型，而`set_config_header`仅用于处理头文件，并且不支持模板变量替换。

先来一个简单的例子：

```lua
target("test")
    set_kind("binary")
    add_files("src/*.c")
    set_configdir("$(buildir)/config")
    add_configfiles("src/config.h.in")
```

上面的设置，会在编译前，自动的将`config.h.in`这个头文件配置模板，经过预处理后，生成输出到指定的`build/config/config.h`。

如果`set_configdir`不设置，那么默认输出到`build`目录下。

其中`.in`后缀会被自动识别处理掉，如果想要输出存储为其他文件名，可以通过：

```lua
add_configfiles("src/config.h", {filename = "myconfig.h"})
```

的方式，来重命名输出，同样，这个接口跟[add_installfiles](#targetadd_configfiles)类似，也是支持prefixdir和子目录提取设置：

```lua
add_configfiles("src/*.h.in", {prefixdir = "subdir"})
add_configfiles("src/(tbox/config.h)") 
```

这个接口的一个最重要的特性就是，可以在预处理的时候，对里面的一些模板变量进行预处理替换，例如：

config.h.in

```
#define VAR1 "${VAR1}"
#define VAR2 "${VAR2}"
#define HELLO "${HELLO}"
```

```lua
set_configvar("VAR1", "1")

target("test")
    set_kind("binary")
    add_files("main.c")

    set_configvar("VAR2", 2)
    add_configfiles("config.h.in", {variables = {hello = "xmake"}})
    add_configfiles("*.man", {copyonly = true})
```

通过[set_configvar](#targetset_configvar)接口设置模板变量，裹着通过`{variables = {xxx = ""}}`中设置的变量进行替换处理。

预处理后的文件`config.h`内容为：

```
#define VAR1 "1"
#define VAR2 "2"
#define HELLO "xmake"
```

而`{copyonly = true}`设置，会强制将`*.man`作为普通文件处理，仅在预处理阶段copy文件，不进行变量替换。

默认的模板变量匹配模式为`${var}`，当然我们也可以设置其他的匹配模式，例如，改为`@var@`匹配规则：

```lua
target("test")
    add_configfiles("config.h.in", {pattern = "@(.-)@"})
```

我们也有提供了一些内置的变量，即使不通过此接口设置，也是可以进行默认变量替换的：

```
${VERSION} -> 1.6.3
${VERSION_MAJOR} -> 1
${VERSION_MINOR} -> 6
${VERSION_ALTER} -> 3
${VERSION_BUILD} -> set_version("1.6.3", {build = "%Y%m%d%H%M"}) -> 201902031421
${PLAT} and ${plat} -> MACOS and macosx
${ARCH} and ${arch} -> ARM and arm
${MODE} and ${mode} -> DEBUG/RELEASE and debug/release
${DEBUG} and ${debug} -> 1 or 0
${OS} and ${os} -> IOS or ios
```

例如：

config.h.in

```c
#define CONFIG_VERSION "${VERSION}"
#define CONFIG_VERSION_MAJOR ${VERSION_MAJOR}
#define CONFIG_VERSION_MINOR ${VERSION_MINOR}
#define CONFIG_VERSION_ALTER ${VERSION_ALTER}
#define CONFIG_VERSION_BUILD ${VERSION_BUILD}
```

config.h

```c
#define CONFIG_VERSION "1.6.3"
#define CONFIG_VERSION_MAJOR 1
#define CONFIG_VERSION_MINOR 6
#define CONFIG_VERSION_ALTER 3
#define CONFIG_VERSION_BUILD 201902031401
```

我们还可以对`#define`定义进行一些变量状态控制处理：

config.h.in 

```c
${define FOO_ENABLE}
```

```lua
set_configvar("FOO_ENABLE", 1) -- or pass true
set_configvar("FOO_STRING", "foo")
```

通过上面的变量设置后，`${define xxx}`就会替换成：

```c
#define FOO_ENABLE 1
#define FOO_STRING "foo"
```

或者（设置为0禁用的时候）

```c
/* #undef FOO_ENABLE */
/* #undef FOO_STRING */
```

这种方式，对于一些自动检测生成config.h非常有用，比如配合option来做自动检测：

```lua
option("foo")
    set_default(true)
    set_description("Enable Foo")
    set_configvar("FOO_ENABLE", 1) -- 或者传递true，启用FOO_ENABLE变量
    set_configvar("FOO_STRING", "foo")

target("test")
    add_configfiles("config.h.in")

    -- 如果启用foo选项 -> 天剑 FOO_ENABLE 和 FOO_STRING 定义
    add_options("foo") 
```

config.h.in

```c
${define FOO_ENABLE}
${define FOO_STRING}
```

config.h

```c
#define FOO_ENABLE 1
#define FOO_STRING "foo"
```

关于option选项检测，以及config.h的自动生成，有一些辅助函数，可以看下：https://github.com/xmake-io/xmake/issues/342

除了`#define`，如果想要对其他非`#define xxx`也做状态切换处理，可以使用 `${default xxx 0}` 模式，设置默认值，例如：

```
HAVE_SSE2 equ ${default VAR_HAVE_SSE2 0}
```

通过`set_configvar("HAVE_SSE2", 1)`启用变量后，变为`HAVE_SSE2 equ 1`，如果没有设置变量，则使用默认值：`HAVE_SSE2 equ 0`

关于这个的详细说明，见：https://github.com/xmake-io/xmake/issues/320


#### 选项定义

定义和设置选项开关，每个`option`对应一个选项，可用于自定义编译配置选项、开关设置。

<p class="tip">
除了`target`以外的所有域接口，例如`option`，`task`等的接口，默认不能放置在外面的全局作用域中的（除非部分跟target共用的接口除外）。
如果要设置值影响所有`option`，`task`等选项，可以通过匿名全局域来设置。
</p>

例如：

```lua
-- 进入option的匿名全局域，里面的设置会同时影响test和test2选项
option()
    add_defines("DEBUG")

option("test")
    -- ... 
    -- 尽量保持缩进，因为这个之后的所有设置，都是针对test选项的

option("test2")
    -- ... 
```

<p class="tip">
`option`域是可以重复进入来实现分离设置的，如果要显示离开当前选项的作用域设置，可以手动调用[option_end](#option_end)接口。
</p>


| 接口                                                  | 描述                                         | 支持版本 |
| ----------------------------------------------------- | -------------------------------------------- | -------- |
| [option](#option)                                     | 定义选项                                     | >= 2.0.1 |
| [option_end](#option_end)                             | 结束定义选项                                 | >= 2.1.1 |
| [add_deps](#optionadd_deps)                           | 添加选项依赖                                 | >= 2.1.5 |
| [before_check](#optionbefore_check)                   | 选项检测之前执行此脚本                       | >= 2.1.5 |
| [on_check](#optionon_check)                           | 自定义选项检测脚本                           | >= 2.1.5 |
| [after_check](#optionafter_check)                     | 选项检测之后执行此脚本                       | >= 2.1.5 |
| [set_values](#optionset_values)                       | 设置选项值列表                               | >= 2.1.9 |
| [set_default](#optionset_default)                     | 设置默认值                                   | >= 2.0.1 |
| [set_showmenu](#optionset_showmenu)                   | 设置是否启用菜单显示                         | >= 1.0.1 |
| [set_category](#optionset_category)                   | 设置选项分类，仅用于菜单显示                 | >= 1.0.1 |
| [set_description](#optionset_description)             | 设置菜单显示描述                             | >= 1.0.1 |
| [add_links](#optionadd_links)                         | 添加链接库检测                               | >= 1.0.1 |
| [add_linkdirs](#optionadd_linkdirs)                   | 添加链接库检测需要的搜索目录                 | >= 1.0.1 |
| [add_rpathdirs](#optionadd_rpathdirs)                 | 添加运行时候动态链接库搜索目录               | >= 2.1.3 |
| [add_cincludes](#optionadd_cincludes)                 | 添加c头文件检测                              | >= 1.0.1 |
| [add_cxxincludes](#optionadd_cxxincludes)             | 添加c++头文件检测                            | >= 1.0.1 |
| [add_ctypes](#optionadd_ctypes)                       | 添加c类型检测                                | >= 1.0.1 |
| [add_cxxtypes](#optionadd_cxxtypes)                   | 添加c++类型检测                              | >= 1.0.1 |
| [add_csnippet](#optionadd_csnippet)                   | 添加c代码片段检测                            | >= 2.1.5 |
| [add_cxxsnippet](#optionadd_cxxsnippet)               | 添加c++代码片段检测                          | >= 2.1.5 |
| [set_warnings](#targetset_warnings)                   | 设置警告级别                                 | >= 1.0.1 |
| [set_optimize](#targetset_optimize)                   | 设置优化级别                                 | >= 1.0.1 |
| [set_languages](#targetset_languages)                 | 设置代码语言标准                             | >= 1.0.1 |
| [add_includedirs](#targetadd_includedirs)             | 添加头文件搜索目录                           | >= 1.0.1 |
| [add_defines](#targetadd_defines)                     | 添加宏定义                                   | >= 1.0.1 |
| [add_undefines](#targetadd_undefines)                 | 取消宏定义                                   | >= 1.0.1 |
| [add_defines_h](#targetadd_defines_h)                 | 添加宏定义到头文件                           | >= 1.0.1 |
| [add_undefines_h](#targetadd_undefines_h)             | 取消宏定义到头文件                           | >= 1.0.1 |
| [add_cflags](#targetadd_cflags)                       | 添加c编译选项                                | >= 1.0.1 |
| [add_cxflags](#targetadd_cxflags)                     | 添加c/c++编译选项                            | >= 1.0.1 |
| [add_cxxflags](#targetadd_cxxflags)                   | 添加c++编译选项                              | >= 1.0.1 |
| [add_mflags](#targetadd_mflags)                       | 添加objc编译选项                             | >= 2.0.1 |
| [add_mxflags](#targetadd_mxflags)                     | 添加objc/objc++编译选项                      | >= 2.0.1 |
| [add_mxxflags](#targetadd_mxxflags)                   | 添加objc++编译选项                           | >= 2.0.1 |
| [add_scflags](#targetadd_scflags)                     | 添加swift编译选项                            | >= 2.1.1 |
| [add_asflags](#targetadd_asflags)                     | 添加汇编编译选项                             | >= 2.1.1 |
| [add_gcflags](#targetadd_gcflags)                     | 添加go编译选项                               | >= 2.1.1 |
| [add_dcflags](#targetadd_dcflags)                     | 添加dlang编译选项                            | >= 2.1.1 |
| [add_rcflags](#targetadd_rcflags)                     | 添加rust编译选项                             | >= 2.1.1 |
| [add_cuflags](#targetadd_cuflags)                     | 添加cuda编译选项                             | >= 2.2.1 |
| [add_culdflags](#targetadd_culdflags)                 | 添加cuda设备链接选项                         | >= 2.2.7 |
| [add_ldflags](#targetadd_ldflags)                     | 添加链接选项                                 | >= 2.1.1 |
| [add_arflags](#targetadd_arflags)                     | 添加静态库归档选项                           | >= 2.1.1 |
| [add_shflags](#targetadd_shflags)                     | 添加动态库链接选项                           | >= 2.0.1 |
| [add_cfuncs](#targetadd_cfuncs)                       | 添加c库函数检测                              | >= 1.0.1 |
| [add_cxxfuncs](#targetadd_cxxfuncs)                   | 添加c++库函数接口                            | >= 1.0.1 |
| [add_languages](#targetadd_languages)                 | 添加语言标准                                 | >= 2.0.1 |
| [add_vectorexts](#targetadd_vectorexts)               | 添加向量扩展指令                             | >= 2.0.1 |
| [add_frameworks](#targetadd_frameworks)               | 添加链接框架                                 | >= 2.1.1 |
| [add_frameworkdirs](#targetadd_frameworkdirs)         | 添加链接框架                                 | >= 2.1.5 |

| 废弃接口                                              | 描述                                         | 支持版本         |
| ----------------------------------------------------- | -------------------------------------------- | ---------------- |
| [add_bindings](#optionadd_bindings)                   | 添加正向关联选项，同步启用和禁用             | >= 2.0.1 < 2.1.5 |
| [add_rbindings](#optionadd_rbindings)                 | 添加逆向关联选项，同步启用和禁用             | >= 2.0.1 < 2.1.5 |
| [add_defines_if_ok](#optionadd_defines_if_ok)         | 如果检测选项通过，则添加宏定义               | >= 1.0.1 < 2.1.5 |
| [add_defines_h_if_ok](#optionadd_defines_h_if_ok)     | 如果检测选项通过，则添加宏定义到配置头文件   | >= 1.0.1 < 2.1.5 |
| [add_undefines_if_ok](#optionadd_undefines_if_ok)     | 如果检测选项通过，则取消宏定义               | >= 1.0.1 < 2.1.5 |
| [add_undefines_h_if_ok](#optionadd_undefines_h_if_ok) | 如果检测选项通过，则在配置头文件中取消宏定义 | >= 1.0.1 < 2.1.5 |

##### option

###### 定义选项

定义和设置选项开关，可用于自定义编译配置选项、开关设置。

例如，定义一个是否启用test的选项：

```lua
option("test")
    set_default(false)
    set_showmenu(true)
    add_defines("TEST")
```

然后关联到指定的target中去：

```lua
target("demo")
    add_options("test")
```

这样，一个选项就算定义好了，如果这个选项被启用，那么编译这个target的时候，就会自动加上`-DTEST`的宏定义。

```lua
# 手动启用这个选项
$ xmake f --test=y
$ xmake
```

##### option_end

###### 结束定义选项

这是一个可选api，显示离开选项作用域，用法和[target_end](#target_end)类似。

##### option:add_deps

###### 添加选项依赖

通过设置依赖，可以调整选项的检测顺序，一般用于[on_check](#optionon_check)等检测脚本的调用时机。

```lua
option("small")
    set_default(true)
    on_check(function (option)
        -- ...
    end)

option("test")
    add_deps("small")
    set_default(true)
    on_check(function (option)
        if option:dep("small"):enabled() then
            option:enable(false)
        end
    end)
```

当依赖的small选项检测完成后，通过判断small选项的状态，来控制test的选项状态。

##### option:before_check

###### 选项检测之前执行此脚本

例如：在检测之前，通过[find_package](#detect-find_package)来查找包，将`links`, `includedirs`和`linkdirs`等信息添加到option中去，
然后开始选项检测，通过后就会自动链接到target上。

```lua
option("zlib")
    before_check(function (option)
        import("lib.detect.find_package")
        option:add(find_package("zlib"))
    end)
```

##### option:on_check

###### 自定义选项检测脚本

此脚本会覆盖内置的选项检测逻辑。

```lua
option("test")
    add_deps("small")
    set_default(true)
    on_check(function (option)
        if option:dep("small"):enabled() then
            option:enable(false)
        end
    end)
```

如果test依赖的选项通过，则禁用test选项。

##### option:after_check

###### 选项检测之后执行此脚本

在选项检测完成后，执行此脚本做一些后期处理，也可以在此时重新禁用选项：

```lua
option("test")
    add_deps("small")
    add_links("pthread")
    after_check(function (option)
        option:enable(false)
    end)
```

##### option:set_values

###### 设置选项值列表

仅用于`xmake f --menu`的图形菜单配置时，提供选项值列表供用户快速选择使用，例如：

```lua
option("test")
    set_default("b")
    set_showmenu(true)
    set_values("a", "b", "c")
```

效果图如下：

<img src="/assets/img/manual/option_set_values.png" width="60%" />

##### option:set_default

###### 设置选项默认值

在没有通过`xmake f --option=[y|n}`等命令修改选项值的时候，这个选项本身也是有个默认值的，可以通过这个接口来设置：

```lua
option("test")
    -- 默认禁用这个选项
    set_default(false)
```

选项的值不仅支持boolean类型，也可以是字符串类型，例如：

```lua
option("test")
    set_default("value")
```

| 值类型  | 描述                                   | 配置                                           |
| ------  | -------------------------------------- | -----------------------------------------------|
| boolean | 一般用作参数开关，值范围：`true/false` | `xmake f --optionname=[y/n/yes/no/true/false]` |
| string  | 可以是任意字符串，一般用于模式判断     | `xmake f --optionname=value`                   |

如果是`boolean`值的选项，可以通过[is_option](#is_option)来进行判断，选项是否被启用。

如果是`string`类型的选项，可以在内建变量中直接使用，例如：

```lua
-- 定义一个路径配置选项，默认使用临时目录
option("rootdir")
    set_default("$(tmpdir)")
    set_showmenu(true)

target("test")
    -- 添加指定选项目录中的源文件
    add_files("$(rootdir)/*.c")
```

其中，`$(rootdir)` 就是自定义的选项内建变量，通过手动配置，可以动态修改它的值：

```bash
$ xmake f --rootdir=~/projectdir/src
$ xmake
```

给这个`rootdir`选项指定一个其他的源码目录路径，然后编译。

选项的检测行为：

| default值  | 检测行为                                                                                      |
| ---------- | --------------------------------------------------------------------------------------------- |
| 没有设置   | 优先手动配置修改，默认禁用，否则自动检测，可根据手动传入的值类型，自动切换boolean和string类型 |
| false      | 开关选项，不自动检测，默认禁用，可手动配置修改                                                |
| true       | 开关选项，不自动检测，默认启用，可手动配置修改                                                |
| string类型 | 无开关状态，不自动检测，可手动配置修改，一般用于配置变量传递                                  |

##### option:set_showmenu

###### 设置是否启用菜单显示

如果设置为`true`，那么在`xmake f --help`里面就会出现这个选项，也就能通过`xmake f --optionname=xxx`进行配置，否则只能在`xmake.lua`内部使用，无法手动配置修改。

```lua
option("test")
    set_showmenu(true)
```

设置为启用菜单后，执行`xmake f --help`可以看到，帮助菜单里面多了一项：

```
Options:
    ...

    --test=TEST
```

##### option:set_category

###### 设置选项分类，仅用于菜单显示

这个是个可选配置，仅用于在帮助菜单中，进行分类显示选项，同一类别的选项，会在同一个分组里面显示，这样菜单看起来更加的美观。

例如：

```lua
option("test1")
    set_showmenu(true)
    set_category("test")

option("test2")
    set_showmenu(true)
    set_category("test")

option("demo1")
    set_showmenu(true)
    set_category("demo")

option("demo2")
    set_showmenu(true)
    set_category("demo")
```

这里四个选项分别归类于两个分组：`test`和`demo`，那么显示的布局类似这样：

```bash
Options:
    ...

    --test1=TEST1
    --test2=TEST2
 
    --demo1=DEMO1
    --demo2=DEMO2
```

这个接口，仅仅是为了调整显示布局，更加美观而已，没其他用途。

在2.1.9版本中，可以通过category设置分级路径名`set_category("root/submenu/submenu2")`，来配置`xmake f --menu`的图形菜单界面，例如：

```lua
-- 'boolean' option
option("test1")
    set_default(true)
    set_showmenu(true)
    set_category("root menu/test1")

-- 'choice' option with values: "a", "b", "c"
option("test2")
    set_default("a")
    set_values("a", "b", "c")
    set_showmenu(true)
    set_category("root menu/test2")

-- 'string' option
option("test3")
    set_default("xx")
    set_showmenu(true)
    set_category("root menu/test3/test3")

-- 'number' option
option("test4")
    set_default(6)
    set_showmenu(true)
    set_category("root menu/test4")
```

上述配置最后显示的菜单界面路径结构：

- root menu
  - test1
  - test2
  - test3
    - test3
  - test4

效果图如下：

<img src="/assets/img/manual/option_set_category.gif" width="60%" />

##### option:set_description

###### 设置菜单显示描述

设置选项菜单显示时，右边的描述信息，用于帮助用户更加清楚的知道这个选项的用途，例如：

```lua
option("test")
    set_default(false)
    set_showmenu(true)
    set_description("Enable or disable test")
```

生成的菜单内容如下：

```
Options:
    ...

    --test=TEST                       Enable or disable test (default: false)
```

这个接口也支持多行显示，输出更加详细的描述信息，例如：

```lua
option("mode")
    set_default("debug")
    set_showmenu(true)
    set_description("Set build mode",
                    "    - debug",
                    "    - release",
                    "    - profile")
```

生成的菜单内容如下：

```
Options:
    ...

    --mode=MODE                       Set build mode (default: debug)
                                          - debug
                                          - release
                                          - profile
```

看到这个菜单，用户就能清楚地知道，定义的这个`mode`选项的具体用处，以及如何使用了：

```bash
$ xmake f --mode=release
```

##### option:add_bindings

###### 添加正向关联选项，同步启用和禁用

<p class="tip">
2.1.5版本之后已废弃，请用[add_deps](#optionadd_deps), [on_check](#optionon_check), [after_check](#optionafter_check)等接口代替。
</p>

绑定关联选项，例如我想在命令行中配置一个`smallest`的参数：`xmake f --smallest=y`

这个时候，需要同时禁用多个其他的选项开关，来禁止编译多个模块，就是这个需求，相当于一个选项 与其他 多个选项之间 是有联动效应的。

而这个接口就是用来设置需要正向绑定的一些关联选项，例如：

```lua
-- 定义选项开关: --smallest=y|n
option("smallest")

    -- 添加正向绑定，如果smallest被启用，下面的所有选项开关也会同步被启用
    add_bindings("nozip", "noxml", "nojson")
```

##### option:add_rbindings

###### 添加逆向关联选项，同步启用和禁用

<p class="tip">
2.1.5版本之后已废弃，请用[add_deps](#optionadd_deps), [on_check](#optionon_check), [after_check](#optionafter_check)等接口代替。
</p>

逆向绑定关联选项，被关联选项的开关状态是相反的。

```lua
-- 定义选项开关: --smallest=y|n
option("smallest")

    -- 添加反向绑定，如果smallest被启用，下面的所有模块全部禁用
    add_rbindings("xml", "zip", "asio", "regex", "object", "thread", "network", "charset", "database")
    add_rbindings("zlib", "mysql", "sqlite3", "openssl", "polarssl", "pcre2", "pcre", "base")
```

<p class="warning">
需要注意的是，命令行配置是有顺序的，你可以先通过启用smallest禁用所有模块，然后添加其他选项，逐一启用。
</p>

例如：

```bash
-- 禁用所有模块，然后仅仅启用xml和zip模块
$ xmake f --smallest=y --xml=y --zip=y
```

##### option:add_links

###### 添加链接库检测

如果指定的链接库检测通过，此选项将被启用，并且对应关联的target会自动加上此链接，例如：

```lua
option("pthread")
    set_default(false)
    add_links("pthread")
    add_linkdirs("/usr/local/lib")

target("test")
    add_options("pthread")
```

如果检测通过，`test`目标编译的时候就会自动加上：`-L/usr/local/lib -lpthread` 编译选项


##### option:add_linkdirs

###### 添加链接库检测时候需要的搜索目录

这个是可选的，一般系统库不需要加这个，也能检测通过，如果确实没找到，可以自己追加搜索目录，提高检测通过率。具体使用见：[add_links](#optionadd_links)

##### option:add_rpathdirs

###### 添加程序运行时动态库的加载搜索目录

在选项通过检测后，会自动添加到对应的target上去，具体使用见：[target.add_rpathdirs](#targetadd_rpathdirs)。

##### option:add_cincludes

###### 添加c头文件检测

如果c头文件检测通过，此选项将被启用，例如：

```lua
option("pthread")
    set_default(false)
    add_cincludes("pthread.h")
    add_defines("ENABLE_PTHREAD")

target("test")
    add_options("pthread")
```

此选项检测是否存在`pthread.h`的头文件，如果检测通过那么`test`目标程序将会加上`ENABLE_PTHREAD`的宏定义。

如果想要更加灵活的检测，可以通过[lib.detect.has_cincludes](#detect-has_cincludes)在[option.on_check](#optionon_check)中去实现。

##### option:add_cxxincludes

###### 添加c++头文件检测

与[add_cincludes](#optionadd_cincludes)类似，只是检测的头文件类型是c++头文件。

##### option:add_ctypes

###### 添加c类型检测 

如果c类型检测通过，此选项将被启用，例如：

```lua
option("wchar")
    set_default(false)
    add_cincludes("wchar_t")
    add_defines("HAVE_WCHAR")

target("test")
    add_options("wchar")
```

此选项检测是否存在`wchar_t`的类型，如果检测通过那么`test`目标程序将会加上`HAVE_WCHAR`的宏定义。

如果想要更加灵活的检测，可以通过[lib.detect.has_ctypes](#detect-has_ctypes)在[option.on_check](#optionon_check)中去实现。

##### option:add_cxxtypes

###### 添加c++类型检测

与[add_ctypes](#optionadd_ctypes)类似，只是检测的类型是c++类型。

##### option:add_csnippet

###### 添加c代码片段检测

如果现有的[add_ctypes](#optionadd_ctypes), [add_cfuncs](#optionadd_cfuncs)等不能满足当前的检测需求，
可以用这个接口实现更加定制化检测一些编译器特性检测，具体见: [add_cxxsnippet](#optionadd_cxxsnippet)。

##### option:add_cxxsnippet

###### 添加c++代码片段检测

可以用这个接口实现更加定制化检测一些编译器特性检测，尤其是c++的各种特性的检测支持，例如：

```lua
option("constexpr")
    add_cxxsnippet("constexpr", "constexpr int f(int x) { int sum=0; for (int i=0; i<=x; ++i) sum += i; return sum; } constexpr int x = f(5);  static_assert(x == 15);")
```

第一个参数设置代码片段的名字作为标示，检测输出信息时候会有显示。

上述代码，实现对c++的constexpr特性的检测，如果检测通过，则启用constexpr选项，当然这里只是个例子。

对于编译器特性的检测，有更加方便高效的检测模块，提供更强大的检测支持，具体见：[compiler.has_features](#compiler-has_features)和[detect.check_cxsnippets](#detect-check_cxsnippets)

如果想要更加灵活的检测，可以通过[lib.detect.check_cxsnippets](#detect-check_cxsnippets)在[option.on_check](#optionon_check)中去实现。

##### option:add_defines_if_ok

###### 如果检测选项通过，则添加宏定义

<p class="tip">
2.1.5版本之后已废弃，请用[add_defines](#targetadd_defines)接口代替。
</p>

检测选项通过后才会被设置，具体使用见[add_cincludes](#optionadd_cincludes)中的例子。

##### option:add_defines_h_if_ok

###### 如果检测选项通过，则添加宏定义到配置头文件

<p class="tip">
2.1.5版本之后已废弃，请用[add_defines_h](#targetadd_defines_h)接口代替。
</p>

跟[add_defines_if_ok](#optionadd_defines_if_ok)类似，只是检测通过后，会在`config.h`头文件中自动加上被设置的宏定义。

例如：

```lua
option("pthread")
    set_default(false)
    add_cincludes("pthread.h")
    add_defines_h_if_ok("ENABLE_PTHREAD")

target("test")
    add_options("pthread")
```

通过后，会在`config.h`中加上：

```c
#define ENABLE_PTHREAD 1
```

具体`config.h`如何设置，见：[set_config_h](#targetset_config_h)

##### option:add_undefines_if_ok

###### 如果检测选项通过，则取消宏定义

<p class="tip">
2.1.5版本之后已废弃，请用[add_undefines](#targetadd_undefines)接口代替。
</p>

跟[add_defines_if_ok](#optionadd_defines_if_ok)类似，只是检测通过后，取消被设置的宏定义。

##### option:add_undefines_h_if_ok

###### 如果检测选项通过，则在配置头文件中取消宏定义

<p class="tip">
2.1.5版本之后已废弃，请用[add_undefines_h](#targetadd_undefines_h)接口代替。
</p>

跟[add_defines_h_if_ok](#optionadd_defines_h_if_ok)类似，只是检测通过后，会在`config.h`中取消被设置的宏定义。

```c
#undef DEFINED_MACRO
```

具体`config.h`如何设置，见：[set_config_h](#targetset_config_h)

#### 插件任务

xmake可以实现自定义任务或者插件，其两者的核心就是`task`任务，其两者实际上是一样的，xmake的插件都是用`task`实现的。

本质上都是任务，只是[set_category](#taskset_category)分类不同而已。

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [task](#task)                                   | 定义插件或者任务                             | >= 2.0.1 |
| [task_end](#task_end)                           | 结束定义插件或任务                           | >= 2.1.1 |
| [set_menu](#taskset_menu)                       | 设置任务菜单                                 | >= 2.0.1 |
| [set_category](#taskset_category)               | 设置任务类别                                 | >= 2.0.1 |
| [on_run](#taskon_run)                           | 设置任务运行脚本                             | >= 2.0.1 |

##### task

###### 定义插件或者任务

`task`域用于描述一个自定义的任务实现，与[target](#target)和[option](#option)同级。

例如，这里定义一个最简单的任务：

```lua
task("hello")

    -- 设置运行脚本
    on_run(function ()
        print("hello xmake!")
    end)
```

这个任务只需要打印`hello xmake!`，那如何来运行呢？

由于这里没有使用[set_menu](#taskset_menu)设置菜单，因此这个任务只能再`xmake.lua`的自定义脚本或者其他任务内部调用，例如：

```lua
target("test")

    after_build(function (target)
 
        -- 导入task模块
        import("core.project.task")

        -- 运行hello任务
        task.run("hello")
    end)
```

在构建完`test`目标后运行`hello`任务。

##### task_end

###### 结束定义插件或任务

这是一个可选api，显示离开选项作用域，用法和[target_end](#target_end)类似。

##### task:set_menu

###### 设置任务菜单

通过设置一个菜单，这个任务就可以开放给用户自己通过命令行手动调用，菜单的设置如下：

```lua
task("echo")

    -- 设置运行脚本
    on_run(function ()

        -- 导入参数选项模块
        import("core.base.option")

        -- 初始化颜色模式
        local modes = ""
        for _, mode in ipairs({"bright", "dim", "blink", "reverse"}) do
            if option.get(mode) then
                modes = modes .. " " .. mode 
            end
        end

        -- 获取参数内容并且显示信息
        cprint("${%s%s}%s", option.get("color"), modes, table.concat(option.get("contents") or {}, " "))
    end)

    -- 设置插件的命令行选项，这里没有任何参数选项，仅仅显示插件描述
    set_menu {
                -- 设置菜单用法
                usage = "xmake echo [options]"

                -- 设置菜单描述
            ,   description = "Echo the given info!"

                -- 设置菜单选项，如果没有选项，可以设置为{}
            ,   options = 
                {
                    -- 设置k模式作为key-only型bool参数
                    {'b', "bright",     "k",  nil,       "Enable bright."               }      
                ,   {'d', "dim",        "k",  nil,       "Enable dim."                  }      
                ,   {'-', "blink",      "k",  nil,       "Enable blink."                }      
                ,   {'r', "reverse",    "k",  nil,       "Reverse color."               }      

                    -- 菜单显示时，空白一行
                ,   {}

                    -- 设置kv作为key-value型参数，并且设置默认值：black
                ,   {'c', "color",      "kv", "black",   "Set the output color."
                                                     ,   "    - red"   
                                                     ,   "    - blue"
                                                     ,   "    - yellow"
                                                     ,   "    - green"
                                                     ,   "    - magenta"
                                                     ,   "    - cyan" 
                                                     ,   "    - white"                  }

                    -- 设置`vs`作为values多值型参数，还有`v`单值类型
                    -- 一般放置在最后，用于获取可变参数列表
                ,   {}
                ,   {nil, "contents",   "vs", nil,       "The info contents."           }
                }
            } 
```

定义完这个任务后，执行`xmake --help`，就会多出一个任务项来：

```
Tasks:

    ...

    echo                    Echo the given info!
```

如果通过[set_category](#taskset_category)设置分类为`plugin`，那么这个任务就是一个插件了：

```
Plugins:

    ...

    echo                    Echo the given info!
```

想要手动运行这个任务，可以执行：

```bash
$ xmake echo hello xmake!
```

就行了，如果要看这个任务定义的菜单，只需要执行：`xmake echo [-h|--help]`，显示结果如下：

```bash
Usage: $xmake echo [options]

Echo the given info!

Options: 
    -v, --verbose                          Print lots of verbose information.
        --backtrace                        Print backtrace information for debugging.
        --profile                          Print performance data for debugging.
        --version                          Print the version number and exit.
    -h, --help                             Print this help message and exit.
                                           
    -F FILE, --file=FILE                   Read a given xmake.lua file.
    -P PROJECT, --project=PROJECT          Change to the given project directory.
                                           Search priority:
                                               1. The Given Command Argument
                                               2. The Envirnoment Variable: XMAKE_PROJECT_DIR
                                               3. The Current Directory
                                           
    -b, --bright                           Enable bright.
    -d, --dim                              Enable dim.
    --, --blink                            Enable blink.
    -r, --reverse                          Reverse color.
                                           
    -c COLOR, --color=COLOR                Set the output color. (default: black)
                                               - red
                                               - blue
                                               - yellow
                                               - green
                                               - magenta
                                               - cyan
                                               - white
                                           
    contents ...                           The info contents.
```

<p class="tip">
其中菜单最开头的部分选项，是xmake内置的常用选项，基本上每个任务都会用到，不需要自己额外定义，简化菜单定义。
</p>

下面，我们来实际运行下这个任务，例如我要显示红色的`hello xmake!`，只需要：

```bash
$ xmake echo -c red hello xmake!
```

也可以使用选项全名，并且加上高亮：

```bash
$ xmake echo --color=red --bright hello xmake!
```

最后面的可变参数列表，在`run`脚本中通过`option.get("contents")`获取，返回的是一个`table`类型的数组。

##### task:set_category

###### 设置任务类别

仅仅用于菜单的分组显示，当然插件默认会用`plugin`，内置任务默认会用：`action`，但也仅仅只是个约定。

<p class="tips">
你可以使用任何自己定义的名字，相同名字会分组归类到一起显示，如果设置为`plugin`，就会显示到xmake的Plugins分组中去。
</p>

例如：

```lua
Plugins: 
    l, lua               Run the lua script.
    m, macro             Run the given macro.
       doxygen           Generate the doxygen document.
       project           Generate the project file.
       hello             Hello xmake!
       app2ipa           Generate .ipa file from the given .app
       echo              Echo the given info!
```

如果没有调用这个接口设置分类，默认使用`Tasks`分组显示，代表普通任务。

##### task:on_run

###### 设置任务运行脚本

可以有两种设置方式，最简单的就是设置内嵌函数：

```lua
task("hello")

    on_run(function ()
        print("hello xmake!")
    end)
```

这种对于小任务很方便，也很简洁，但是对于大型任务就不太适用了，例如插件等，需要复杂的脚本支持。

这个时候就需要独立的模块文件来设置运行脚本，例如：

```lua
task("hello")
    on_run("main")
```

这里的`main`设置为脚本运行主入口模块，文件名为`main.lua`，放在定义`task`的`xmake.lua`的同目录下，当然你可以起其他文件名。

目录结构如下：

```
projectdir
    - xmake.lua
    - main.lua
```

`main.lua`里面内容如下：

```lua
function main(...)
    print("hello xmake!")
end
```

就是一个简单的带`main`主函数的脚本文件，你可以通过[import](#import)导入各种扩展模块，实现复杂功能，例如：

```lua
-- 导入参数选项模块
import("core.base.option")

-- 入口函数
function main(...)

    -- 获取参数内容
    print("color: %s", option.get("color"))
end
```

你也可以在当前目录下，创建多个自定义的模块文件，通过[import](#import)导入后使用，例如：

```
projectdir
    - xmake.lua
    - main.lua
    - module.lua
```

`module.lua`的内容如下：

```lua
-- 定义一个导出接口
function hello()
    print("hello xmake!")
end
```

<p class="tip">
私有接口，通过`_hello`带下滑线前缀命名，这样导入的模块就不会包含此接口，只在模块自身内部使用。
</p>

然后在`main.lua`进行调用：


```lua
import("module")

function main(...)
    module.hello()
end
```

更多模块介绍见：[内置模块](#内置模块)和[扩展模块](扩展模块)

其中，`main(...)`中参数，是通过`task.run`指定的，例如：

```lua
task.run("hello", {color="red"}, arg1, arg2, arg3)
```

里面的`arg1, arg2`这些就是传入`hello`任务`main(...)`入口的参数列表，而`{color="red"}`用来指定任务菜单中的参数选项。

更加详细的`task.run`描述，见：[task.run](#task-run)

#### 构建规则

在2.2.1版本之后，xmake不仅原生内置支持多种语言文件的构建，而且还可以通过自定义构建规则，让用户自己来实现复杂的未知文件构建。

我们可以通过预先设置规则支持的文件后缀，来扩展其他文件的构建支持：

```lua
-- 定义一个markdown文件的构建规则
rule("markdown")
    set_extensions(".md", ".markdown")
    on_build_file(function (target, sourcefile, opt)
        os.cp(sourcefile, path.join(target:targetdir(), path.basename(sourcefile) .. ".html"))
    end)

target("test")
    set_kind("binary")
    
    -- 使test目标支持markdown文件的构建规则
    add_rules("markdown")

    -- 添加markdown文件的构建
    add_files("src/*.md")
    add_files("src/*.markdown")
```

我们也可以指定某些零散的其他文件作为markdown规则来处理：

```lua
target("test")
    -- ...
    add_files("src/test/*.md.in", {rule = "markdown"})
```

一个target可以叠加应用多个rules去更加定制化实现自己的构建行为，甚至支持不同的构建环境。

<p class="tips">
通过`add_files("*.md", {rule = "markdown"})`方式指定的规则，优先级高于`add_rules("markdown")`设置的规则。
</p>

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [rule](#rule)                                   | 定义规则                                     | >= 2.1.9 |
| [add_imports](#ruleadd_imports)                 | 为所有自定义脚本预先导入扩展模块             | >= 2.1.9 |
| [set_extensions](#ruleset_extensions)           | 设置规则支持的文件扩展类型                   | >= 2.1.9 |
| [on_load](#ruleon_load)                         | 自定义加载脚本                               | >= 2.2.1 |
| [on_link](#ruleon_link)                         | 自定义链接脚本                               | >= 2.2.7 |
| [on_build](#ruleon_build)                       | 自定义编译脚本                               | >= 2.1.9 |
| [on_clean](#ruleon_clean)                       | 自定义清理脚本                               | >= 2.1.9 |
| [on_package](#ruleon_package)                   | 自定义打包脚本                               | >= 2.1.9 |
| [on_install](#ruleon_install)                   | 自定义安装脚本                               | >= 2.1.9 |
| [on_uninstall](#ruleon_uninstall)               | 自定义卸载脚本                               | >= 2.1.9 |
| [on_build_file](#ruleon_build_file)             | 自定义编译脚本, 实现单文件构建               | >= 2.2.1 |
| [on_build_files](#ruleon_build_files)           | 自定义编译脚本, 实现多文件构建               | >= 2.2.1 |
| [before_load](#rulebefore_load)                 | 自定义加载前的脚本                           | >= 2.2.1 |
| [before_link](#rulebefore_link)                 | 自定义链接前的脚本                           | >= 2.2.7 |
| [before_build](#rulebefore_build)               | 自定义编译前的脚本                           | >= 2.2.1 |
| [before_clean](#rulebefore_clean)               | 自定义清理前的脚本                           | >= 2.2.1 |
| [before_package](#rulebefore_package)           | 自定义打包前的脚本                           | >= 2.2.1 |
| [before_install](#rulebefore_install)           | 自定义安装前的脚本                           | >= 2.2.1 |
| [before_uninstall](#rulebefore_uninstall)       | 自定义卸载前的脚本                           | >= 2.2.1 |
| [before_build_file](#rulebefore_build_file)     | 自定义编译前的脚本, 实现单文件构建           | >= 2.2.1 |
| [before_build_files](#rulebefore_build_files)   | 自定义编译前的脚本, 实现多文件构建           | >= 2.2.1 |
| [after_load](#ruleafter_load)                   | 自定义加载后的脚本                           | >= 2.2.1 |
| [after_link](#ruleafter_link)                   | 自定义链接后的脚本                           | >= 2.2.7 |
| [after_build](#ruleafter_build)                 | 自定义编译后的脚本                           | >= 2.2.1 |
| [after_clean](#ruleafter_clean)                 | 自定义清理后的脚本                           | >= 2.2.1 |
| [after_package](#ruleafter_package)             | 自定义打包后的脚本                           | >= 2.2.1 |
| [after_install](#ruleafter_install)             | 自定义安装后的脚本                           | >= 2.2.1 |
| [after_uninstall](#ruleafter_uninstall)         | 自定义卸载后的脚本                           | >= 2.2.1 |
| [after_build_file](#ruleafter_build_file)       | 自定义编译后的脚本, 实现单文件构建           | >= 2.2.1 |
| [after_build_files](#ruleafter_build_files)     | 自定义编译后的脚本, 实现多文件构建           | >= 2.2.1 |
| [rule_end](#rule_end)                           | 结束定义规则                                 | >= 2.1.9 |

##### 内建规则

自从2.2.1版本后，xmake提供了一些内置规则去简化日常xmake.lua描述，以及一些常用构建环境的支持。

| 规则                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [mode.debug](#mode-debug)                       | 调试模式编译规则                             | >= 2.2.1 |
| [mode.release](#mode-release)                   | 发布模式编译规则                             | >= 2.2.1 |
| [mode.check](#mode-check)                       | 检测模式编译规则                             | >= 2.2.1 |
| [mode.profile](#mode-profile)                   | 性能分析模式编译规则                         | >= 2.2.1 |
| [mode.coverage](#mode-coverage)                 | 覆盖分析编译模式规则                         | >= 2.2.1 |
| [qt.static](#qt-static)                         | Qt静态库编译规则                             | >= 2.2.1 |
| [qt.shared](#qt-shared)                         | Qt动态库编译规则                             | >= 2.2.1 |
| [qt.console](#qt-console)                       | Qt控制台编译规则                             | >= 2.2.1 |
| [qt.application](#qt-application)               | Qt应用程序编译规则                           | >= 2.2.1 |
| [wdk.umdf.driver](#wdk-umdf-driver)             | WDK环境umdf驱动编译规则                      | >= 2.2.1 |
| [wdk.umdf.binary](#wdk-umdf-binary)             | WDK环境umdf驱动应用编译规则                  | >= 2.2.1 |
| [wdk.kmdf.driver](#wdk-kmdf-driver)             | WDK环境kmdf驱动编译规则                      | >= 2.2.1 |
| [wdk.kmdf.binary](#wdk-kmdf-binary)             | WDK环境kmdf驱动应用编译规则                  | >= 2.2.1 |
| [wdk.wdm.driver](#wdk-wdm-driver)               | WDK环境wdm驱动编译规则                       | >= 2.2.1 |
| [wdk.wdm.binary](#wdk-wdm-binary)               | WDK环境wdm驱动应用编译规则                   | >= 2.2.1 |

###### mode.debug

为当前工程xmake.lua添加debug编译模式的配置规则，例如：

```lua
add_rules("mode.debug")
```

相当于：

```lua
-- the debug mode
if is_mode("debug") then
    
    -- enable the debug symbols
    set_symbols("debug")

    -- disable optimization
    set_optimize("none")
end
```

我们可以通过：`xmake f -m debug`来切换到此编译模式。

###### mode.release

为当前工程xmake.lua添加release编译模式的配置规则，例如：

```lua
add_rules("mode.release")
```

相当于：

```lua
-- the release mode
if is_mode("release") then

    -- set the symbols visibility: hidden
    set_symbols("hidden")

    -- enable fastest optimization
    set_optimize("fastest")

    -- strip all symbols
    set_strip("all")
end
```

我们可以通过：`xmake f -m release`来切换到此编译模式。

###### mode.check

为当前工程xmake.lua添加check编译模式的配置规则，一般用于内存检测，例如：

```lua
add_rules("mode.check")
```

相当于：

```lua
-- the check mode
if is_mode("check") then

    -- enable the debug symbols
    set_symbols("debug")

    -- disable optimization
    set_optimize("none")

    -- attempt to enable some checkers for pc
    add_cxflags("-fsanitize=address", "-ftrapv")
    add_mxflags("-fsanitize=address", "-ftrapv")
    add_ldflags("-fsanitize=address")
end
```

我们可以通过：`xmake f -m check`来切换到此编译模式。

###### mode.profile

为当前工程xmake.lua添加profile编译模式的配置规则，一般用于性能分析，例如：

```lua
add_rules("mode.profile")
```

相当于：

```lua
-- the profile mode
if is_mode("profile") then
   
    -- enable the debug symbols
    set_symbols("debug")

    -- enable gprof
    add_cxflags("-pg")
    add_ldflags("-pg")
end
```

我们可以通过：`xmake f -m profile`来切换到此编译模式。

###### mode.coverage

为当前工程xmake.lua添加coverage编译模式的配置规则，一般用于覆盖分析，例如：

```lua
add_rules("mode.coverage")
```

相当于：

```lua
-- the coverage mode
if is_mode("coverage") then
    add_cxflags("--coverage")
    add_mxflags("--coverage")
    add_ldflags("--coverage")
end
```

我们可以通过：`xmake f -m coverage`来切换到此编译模式。

###### qt.static

用于编译生成Qt环境的静态库程序：

```lua
target("qt_static_library")
    add_rules("qt.static")
    add_files("src/*.cpp")
    add_frameworks("QtNetwork", "QtGui")
```

###### qt.shared

用于编译生成Qt环境的动态库程序：

```lua
target("qt_shared_library")
    add_rules("qt.shared")
    add_files("src/*.cpp")
    add_frameworks("QtNetwork", "QtGui")
```

###### qt.console

用于编译生成Qt环境的控制台程序：

```lua
target("qt_console")
    add_rules("qt.console")
    add_files("src/*.cpp")
```

###### qt.application

用于编译生成Qt环境的ui应用程序。

Quick(qml)应用程序：

```lua
target("qt_quickapp")
    add_rules("qt.application")
    add_files("src/*.cpp") 
    add_files("src/qml.qrc")
    add_frameworks("QtQuick")
```

Qt Widgets(ui/moc)应用程序:

```lua
-- add target
target("qt_widgetapp")
    add_rules("qt.application")
    add_files("src/*.cpp") 
    add_files("src/mainwindow.ui")
    add_files("src/mainwindow.h")  -- 添加带有 Q_OBJECT 的meta头文件
    add_frameworks("QtWidgets")
```

更多Qt相关描述见：[#160](https://github.com/xmake-io/xmake/issues/160)

###### wdk.env.kmdf

应用WDK下kmdf的编译环境设置，需要配合：`wdk.[driver|binary|static|shared]`等规则来使用。

###### wdk.env.umdf

应用WDK下umdf的编译环境设置，需要配合：`wdk.[driver|binary|static|shared]`等规则来使用。

###### wdk.env.wdm

应用WDK下wdm的编译环境设置，需要配合：`wdk.[driver|binary|static|shared]`等规则来使用。

###### wdk.driver

编译生成windows下基于WDK环境的驱动程序，目前仅支持WDK10环境。

注：需要配合：`wdk.env.[umdf|kmdf|wdm]`等环境规则使用。

```lua
-- add target
target("echo")

    -- add rules
    add_rules("wdk.driver", "wdk.env.kmdf")

    -- add files
    add_files("driver/*.c") 
    add_files("driver/*.inx")

    -- add includedirs
    add_includedirs("exe")
```

###### wdk.binary

编译生成windows下基于WDK环境的可执行程序，目前仅支持WDK10环境。

注：需要配合：`wdk.env.[umdf|kmdf|wdm]`等环境规则使用。

```lua
-- add target
target("app")

    -- add rules
    add_rules("wdk.binary", "wdk.env.umdf")

    -- add files
    add_files("exe/*.cpp") 
```

###### wdk.static

编译生成windows下基于WDK环境的静态库程序，目前仅支持WDK10环境。

注：需要配合：`wdk.env.[umdf|kmdf|wdm]`等环境规则使用。

```lua
target("nonpnp")

    -- add rules
    add_rules("wdk.static", "wdk.env.kmdf")

    -- add flags for rule: wdk.tracewpp
    add_values("wdk.tracewpp.flags", "-func:TraceEvents(LEVEL,FLAGS,MSG,...)", "-func:Hexdump((LEVEL,FLAGS,MSG,...))")

    -- add files
    add_files("driver/*.c", {rule = "wdk.tracewpp"}) 
```

###### wdk.shared

编译生成windows下基于WDK环境的动态库程序，目前仅支持WDK10环境。

注：需要配合：`wdk.env.[umdf|kmdf|wdm]`等环境规则使用。

```lua
target("nonpnp")

    -- add rules
    add_rules("wdk.shared", "wdk.env.wdm")

    -- add flags for rule: wdk.tracewpp
    add_values("wdk.tracewpp.flags", "-func:TraceEvents(LEVEL,FLAGS,MSG,...)", "-func:Hexdump((LEVEL,FLAGS,MSG,...))")

    -- add files
    add_files("driver/*.c", {rule = "wdk.tracewpp"}) 
```

###### wdk.tracewpp

用于启用tracewpp预处理源文件：

```lua
target("nonpnp")

    -- add rules
    add_rules("wdk.driver", "wdk.env.kmdf")

    -- add flags for rule: wdk.tracewpp
    add_values("wdk.tracewpp.flags", "-func:TraceEvents(LEVEL,FLAGS,MSG,...)", "-func:Hexdump((LEVEL,FLAGS,MSG,...))")

    -- add files
    add_files("driver/*.c", {rule = "wdk.tracewpp"}) 
    add_files("driver/*.rc")
```

更多WDK规则描述见：[#159](https://github.com/xmake-io/xmake/issues/159)

###### win.sdk.application

编译生成winsdk应用程序。

```lua
-- add rules
add_rules("mode.debug", "mode.release")

-- define target
target("usbview")

    -- windows application
    add_rules("win.sdk.application")

    -- add files
    add_files("*.c", "*.rc")
    add_files("xmlhelper.cpp", {rule = "win.sdk.dotnet"})
```

###### wdk.sdk.dotnet

用于指定某些c++源文件作为c++.net来编译。

```lua
add_files("xmlhelper.cpp", {rule = "win.sdk.dotnet"})
```

##### rule

###### 定义规则

```lua
rule("markdown")
    set_extensions(".md", ".markdown")
    on_build_file(function (target, sourcefile, opt)
        os.cp(sourcefile, path.join(target:targetdir(), path.basename(sourcefile) .. ".html"))
    end)
```

##### rule:add_imports

###### 为所有自定义脚本预先导入扩展模块

使用方式和说明请见：[target:add_imports](#targetadd_imports)，用法相同。

##### rule:set_extensions

###### 设置规则支持的文件扩展类型

通过设置支持的扩展文件类型，将规则应用于带这些后缀的文件上，例如：

```lua
-- 定义一个markdown文件的构建规则
rule("markdown")
    set_extensions(".md", ".markdown")
    on_build_file(function (target, sourcefile, opt)
        os.cp(sourcefile, path.join(target:targetdir(), path.basename(sourcefile) .. ".html"))
    end)

target("test")
    set_kind("binary")
    
    -- 使test目标支持markdown文件的构建规则
    add_rules("markdown")

    -- 添加markdown文件的构建
    add_files("src/*.md")
    add_files("src/*.markdown")
```

##### rule:on_load

###### 自定义加载脚本

用于实现自定规则的加载脚本，当加载target的时候，会被执行，可在里面自定义设置一些target配置，例如：

```lua
rule("test")
    on_load(function (target)
        target:add("defines", "-DTEST")
    end)
```

##### rule:on_link

###### 自定义链接脚本

用于实现自定规则的链接脚本，会覆盖被应用的target的默认链接行为，例如：

```lua
rule("test")
    on_link(function (target)
    end)
```

##### rule:on_build

###### 自定义编译脚本

用于实现自定规则的构建脚本，会覆盖被应用的target的默认构建行为，例如：

```lua
rule("markdown")
    on_build(function (target)
    end)
```

##### rule:on_clean

###### 自定义清理脚本

用于实现自定规则的清理脚本会，覆盖被应用的target的默认清理行为，例如：

```lua
rule("markdown")
    on_clean(function (target)
        -- remove sourcefile.html
    end)
```

##### rule:on_package

###### 自定义打包脚本

用于实现自定规则的打包脚本，覆盖被应用的target的默认打包行为, 例如：

```lua
rule("markdown")
    on_package(function (target)
        -- package sourcefile.html
    end)
```

##### rule:on_install

###### 自定义安装脚本

用于实现自定规则的安装脚本，覆盖被应用的target的默认安装行为, 例如：

```lua
rule("markdown")
    on_install(function (target)
    end)
```

##### rule:on_uninstall

###### 自定义卸载脚本

用于实现自定规则的卸载脚本，覆盖被应用的target的默认卸载行为, 例如：

```lua
rule("markdown")
    on_uninstall(function (target)
    end)
```

##### rule:on_build_file

###### 自定义编译脚本，一次处理一个源文件

```lua
rule("markdown")
    on_build_file(function (target, sourcefile, opt)
        print("%%%d: %s", opt.progress, sourcefile)
    end)
```

其中第三个参数opt是可选参数，用于获取一些编译过程中的信息状态，例如：opt.progress 为当期的编译进度。

##### rule:on_build_files

###### 自定义编译脚本，一次处理多个源文件

大部分的自定义构建规则，每次都是处理单独一个文件，输出一个目标文件，例如：a.c => a.o

但是，有些情况下，我们需要同时输入多个源文件一起构建生成一个目标文件，例如：a.c b.c d.c => x.o

对于这种情况，我们可以通过自定义这个脚本来实现：

```lua
rule("markdown")
    on_build_files(function (target, sourcebatch, opt)
        -- build some source files
        for _, sourcefile in ipairs(sourcebatch.sourcefiles) do
            -- ...
        end
    end)
```

##### rule:before_load

###### 自定义加载前脚本

用于实现自定义target加载前的执行脚本，例如：

```lua
rule("test")
    before_load(function (target)
        target:add("defines", "-DTEST")
    end)
```

##### rule:before_link

###### 自定义链接前脚本

用于实现自定义target链接前的执行脚本，例如：

```lua
rule("test")
    before_link(function (target)
    end)
```

##### rule:before_build

###### 自定义编译前脚本

用于实现自定义target构建前的执行脚本，例如：

```lua
rule("markdown")
    before_build(function (target)
    end)
```

##### rule:before_clean

###### 自定义清理前脚本

用于实现自定义target清理前的执行脚本，例如：

```lua
rule("markdown")
    before_clean(function (target)
    end)
```

##### rule:before_package

###### 自定义打包前脚本

用于实现自定义target打包前的执行脚本, 例如：

```lua
rule("markdown")
    before_package(function (target)
    end)
```

##### rule:before_install

###### 自定义安装前脚本

用于实现自定义target安装前的执行脚本，例如：

```lua
rule("markdown")
    before_install(function (target)
    end)
```

##### rule:before_uninstall

###### 自定义卸载前脚本

用于实现自定义target卸载前的执行脚本，例如：

```lua
rule("markdown")
    before_uninstall(function (target)
    end)
```

##### rule:before_build_file

###### 自定义编译前脚本，一次处理一个源文件

跟[rule:on_build_file](#ruleon_build_file)用法类似，不过这个接口被调用的时机是在编译某个源文件之前，
一般用于对某些源文件进行编译前的预处理。

##### rule:before_build_files

###### 自定义编译前脚本，一次处理多个源文件

跟[rule:on_build_files](#ruleon_build_files)用法类似，不过这个接口被调用的时机是在编译某些源文件之前，
一般用于对某些源文件进行编译前的预处理。

##### rule:after_load

###### 自定义加载后脚本

用于实现自定义target加载后的执行脚本，用法跟[rule:before_load](#rulebefore_load)类似。

##### rule:after_link

###### 自定义链接后脚本

用于实现自定义target链接后的执行脚本，用法跟[rule:before_link](#rulebefore_link)类似。

##### rule:after_build

###### 自定义编译后脚本

用于实现自定义target构建后的执行脚本，用法跟[rule:before_build](#rulebefore_build)类似。

##### rule:after_clean

###### 自定义清理后脚本

用于实现自定义target清理后的执行脚本，用法跟[rule:before_clean](#rulebefore_clean)类似。

##### rule:after_package

###### 自定义打包后脚本

用于实现自定义target打包后的执行脚本, 用法跟[rule:before_package](#rulebefore_package)类似。

##### rule:after_install

###### 自定义安装后脚本

用于实现自定义target安装后的执行脚本，用法跟[rule:before_install](#rulebefore_install)类似。

##### rule:after_uninstall

###### 自定义卸载后脚本

用于实现自定义target卸载后的执行脚本，用法跟[rule:before_uninstall](#rulebefore_uninstall)类似。

##### rule:after_build_file

###### 自定义编译后脚本，一次处理一个源文件

跟[rule:on_build_file](#ruleon_build_file)用法类似，不过这个接口被调用的时机是在编译某个源文件之后，
一般用于对某些编译后对象文件进行后期处理。

##### rule:after_build_files

###### 自定义编译后脚本，一次处理多个源文件

跟[rule:on_build_files](#ruleon_build_files)用法类似，不过这个接口被调用的时机是在编译某些源文件之后，
一般用于对某些编译后对象文件进行后期处理。

##### rule_end

###### 结束定义规则

这个是可选的，如果想要手动结束rule的定义，可以调用它：

```lua
rule("test")
    -- ..
rule_end()
```

#### 库包依赖

仓库依赖包定义描述，`package()`相关接口定义，等有时间会详细说明，敬请期待。。

可先参考官方仓库中现有包描述：[xmake-repo](https://github.com/xmake-io/xmake-repo)

这里给个比较具有代表性的实例供参考：

```lua
package("libxml2")

    set_homepage("http://xmlsoft.org/")
    set_description("The XML C parser and toolkit of Gnome.")

    set_urls("https://github.com/GNOME/libxml2/archive/$(version).zip", {excludes = {"*/result/*", "*/test/*"}})

    add_versions("v2.9.8", "c87793e45e66a7aa19200f861873f75195065de786a21c1b469bdb7bfc1230fb")
    add_versions("v2.9.7", "31dd4c0e10fa625b47e27fd6a5295d246c883f214da947b9a4a9e13733905ed9")

    if is_plat("macosx", "linux") then
        add_deps("autoconf", "automake", "libtool", "pkg-config")
    end

    on_load(function (package)
        package:addvar("includedirs", "include/libxml2")
        package:addvar("links", "xml2")
    end)

    if is_plat("windows") and winos.version():gt("winxp") then
        on_install("windows", function (package)
            os.cd("win32")
            os.vrun("cscript configure.js iso8859x=yes iconv=no compiler=msvc cruntime=/MT debug=%s prefix=\"%s\"", package:debug() and "yes" or "no", package:installdir())
            os.vrun("nmake /f Makefile.msvc")
            os.vrun("nmake /f Makefile.msvc install")
        end)
    end

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package, {"--disable-dependency-tracking", "--without-python", "--without-lzma"})
    end)
```

#### 内置变量

xmake提供了 `$(varname)` 的语法，来支持内置变量的获取，例如：

```lua
add_cxflags("-I$(buildir)")
```

它将会在在实际编译的时候，将内置的 `buildir` 变量转换为实际的构建输出目录：`-I./build`

一般内置变量可用于在传参时快速获取和拼接变量字符串，例如：

```lua
target("test")

    -- 添加工程源码目录下的源文件
    add_files("$(projectdir)/src/*.c")

    -- 添加构建目录下的头文件搜索路径
    add_includedirs("$(buildir)/inc")
```

也可以在自定义脚本的模块接口中使用，例如：

```lua
target("test")
    on_run(function (target)
        -- 复制当前脚本目录下的头文件到输出目录
        os.cp("$(scriptdir)/xxx.h", "$(buildir)/inc")
    end)
```

所有的内置变量，也可以通过[val](#val)接口，来获取他们的值。

这种使用内置变量的方式，使得描述编写更加的简洁易读，下面是一些xmake内置的变量，可以直接获取：

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [$(os)](#var-os)                                | 获取当前编译平台的操作系统                   | >= 2.0.1 |
| [$(host)](#var-host)                            | 获取本机操作系统                             | >= 2.0.1 |
| [$(tmpdir)](#var-tmpdir)                        | 获取临时目录                                 | >= 2.0.1 |
| [$(curdir)](#var-curdir)                        | 获取当前目录                                 | >= 2.0.1 |
| [$(buildir)](#var-buildir)                      | 获取构建输出目录                             | >= 2.0.1 |
| [$(scriptdir)](#var-scriptdir)                  | 获取工程描述脚本目录                         | >= 2.1.1 |
| [$(globaldir)](#var-globaldir)                  | 获取全局配置目录                             | >= 2.0.1 |
| [$(configdir)](#var-configdir)                  | 获取本地工程配置目录                         | >= 2.0.1 |
| [$(programdir)](#var-programdir)                | xmake安装脚本目录                            | >= 2.1.5 |
| [$(projectdir)](#var-projectdir)                | 获取工程根目录                               | >= 2.0.1 |
| [$(shell)](#var-shell)                          | 执行外部shell命令                            | >= 2.0.1 |
| [$(env)](#var-env)                              | 获取外部环境变量                             | >= 2.1.5 |
| [$(reg)](#var-reg)                              | 获取windows注册表配置项的值                  | >= 2.1.5 |

当然这种变量模式，也是可以扩展的，默认通过`xmake f --var=val`命令，配置的参数都是可以直接获取，例如：

```lua
target("test")
    add_defines("-DTEST=$(var)")
```

<p class="tip">
所有`xmake f --xxx=...`配置的参数值，都是可以通过内置变量获取到，例如：`xmake f --arch=x86`对应`$(arch)`，其他的还有`$(plat)`, `$(mode)`等等。
具体有哪些参数，可以通过：`xmake f -h`才查看。
</p>

既然支持直接从配置选项中获取，那么当然也就能很方便的扩展自定义的选项，来获取自定义的变量了，具体如何自定义选项见：[option](#option)

##### var.$(os)

###### 获取当前编译平台的操作系统

如果当前编译的是iphoneos，那么这个值就是：`ios`，以此类推。

##### var.$(host)

###### 获取本机操作系统

指的是当前本机环境的主机系统，如果你是在macOS上编译，那么系统就是：`macosx`

##### var.$(tmpdir)

###### 获取临时目录

一般用于临时存放一些非永久性文件。

##### var.$(curdir)

###### 获取当前目录

一般默认是执行`xmake`命令时的工程根目录，当然如果通过[os.cd](#os-cd)改变了目录的话，这个值也会一起改变。

##### var.$(buildir)

###### 获取当前的构建输出目录

默认一般为当前工程根目录下的：`./build`目录，也可以通过执行：`xmake f -o /tmp/build`命令来修改默认的输出目录。

##### var.$(scriptdir)

###### 获取当前工程描述脚本的目录

也就是对应`xmake.lua`所在的目录路径。

##### var.$(globaldir)

###### 全局配置目录

xmake的`xmake g|global`全局配置命令，数据存储的目录路径，在里面可以放置一些自己的插件、平台脚本。

默认为：`~/.config`

##### var.$(configdir)

###### 当前工程配置目录

当前工程的配置存储目录，也就是`xmake f|config`配置命令的存储目录，默认为：`projectdir/.config`

##### var.$(programdir)

###### xmake安装脚本目录

也就是`XMAKE_PROGRAM_DIR`环境变量所在目录，我们也可以通过设置这个环境量，来修改xmake的加载脚本，实现版本切换。

##### var.$(projectdir)

###### 工程根目录

也就是`xmake -P xxx`命令中指定的目录路径，默认不指定就是`xmake`命令执行时的当前目录，一般用于定位工程文件。

##### var.$(shell)

###### 执行外部shell命令

除了内置的变量处理，xmake还支持原生shell的运行，来处理一些xmake内置不支持的功能

例如，现在有个需求，我想用在编译linux程序时，调用`pkg-config`获取到实际的第三方链接库名，可以这么做：

```lua
target("test")
    set_kind("binary")
    if is_plat("linux") then
        add_ldflags("$(shell pkg-config --libs sqlite3)")
    end
```

当然，xmake有自己的自动化第三库检测机制，一般情况下不需要这么麻烦，而且lua自身的脚本化已经很不错了。。

但是这个例子可以说明，xmake是完全可以通过原生shell，来与一些第三方的工具进行配合使用。。

##### var.$(env)

###### 获取外部环境变量

例如，可以通过获取环境变量中的路径：

```lua
target("test")
    add_includedirs("$(env PROGRAMFILES)/OpenSSL/inc")
```

##### var.$(reg)

###### 获取windows注册表配置项的值 

通过 `regpath; name` 的方式获取注册表中某个项的值：

```lua
print("$(reg HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\XXXX;Name)")
```

#### 内置模块

在自定义脚本、插件脚本、任务脚本、平台扩展、模板扩展等脚本代码中使用，也就是在类似下面的代码块中，可以使用这些模块接口：

```lua
on_run(function (target)
    print("hello xmake!")
end)
```

<p class="warning">
为了保证外层的描述域尽可能简洁、安全，一般不建议在这个域使用接口和模块操作api，因此大部分模块接口只能脚本域使用，来实现复杂功能。</br>
当然少部分只读的内置接口还是可以在描述域使用的，具体见下表：
</p>

| 接口                                            | 描述                                         | 可使用域                   | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------------------------- | -------- |
| [val](#val)                                     | 获取内置变量的值                             | 脚本域                     | >= 2.1.5 |
| [import](#import)                               | 导入扩展摸块                                 | 脚本域                     | >= 2.0.1 |
| [inherit](#inherit)                             | 导入并继承基类模块                           | 脚本域                     | >= 2.0.1 |
| [ifelse](#ifelse)                               | 类似三元条件判断                             | 描述域、脚本域             | >= 2.0.1 |
| [try-catch-finally](#try-catch-finally)         | 异常捕获                                     | 脚本域                     | >= 2.0.1 |
| [pairs](#pairs)                                 | 用于遍历字典                                 | 描述域、脚本域             | >= 2.0.1 |
| [ipairs](#ipairs)                               | 用于遍历数组                                 | 描述域、脚本域             | >= 2.0.1 |
| [print](#print)                                 | 换行打印终端日志                             | 描述域、脚本域             | >= 2.0.1 |
| [printf](#printf)                               | 无换行打印终端日志                           | 脚本域                     | >= 2.0.1 |
| [cprint](#cprint)                               | 换行彩色打印终端日志                         | 脚本域                     | >= 2.0.1 |
| [cprintf](#cprintf)                             | 无换行彩色打印终端日志                       | 脚本域                     | >= 2.0.1 |
| [format](#format)                               | 格式化字符串                                 | 描述域、脚本域             | >= 2.0.1 |
| [vformat](#vformat)                             | 格式化字符串，支持内置变量转义               | 脚本域                     | >= 2.0.1 |
| [raise](#raise)                                 | 抛出异常中断程序                             | 脚本域                     | >= 2.0.1 |
| [os](#os)                                       | 系统操作模块                                 | 部分只读操作描述域、脚本域 | >= 2.0.1 |
| [io](#io)                                       | 文件操作模块                                 | 脚本域                     | >= 2.0.1 |
| [path](#path)                                   | 路径操作模块                                 | 描述域、脚本域             | >= 2.0.1 |
| [table](#table)                                 | 数组和字典操作模块                           | 描述域、脚本域             | >= 2.0.1 |
| [string](#string)                               | 字符串操作模块                               | 描述域、脚本域             | >= 2.0.1 |
| [process](#process)                             | 进程操作模块                                 | 脚本域                     | >= 2.0.1 |
| [coroutine](#coroutine)                         | 协程操作模块                                 | 脚本域                     | >= 2.0.1 |
| [find_packages](#find_packages)                 | 查找依赖包                                   | 脚本域                     | >= 2.2.5 |

在描述域使用接口调用的实例如下，一般仅用于条件控制：

```lua
-- 扫描当前xmake.lua目录下的所有子目录，以每个目录的名字定义一个task任务
for _, taskname in ipairs(os.dirs("*"), path.basename) do
    task(taskname)
        on_run(function ()
        end)
end
```

上面所说的脚本域、描述域主要是指：

```lua
-- 描述域
target("test")
    
    -- 描述域
    set_kind("static")
    add_files("src/*.c")

    on_run(function (target)
        -- 脚本域
    end)

-- 描述域
```

##### val

###### 获取内置变量的值

[内置变量](#内置变量)可以通过此接口直接获取，而不需要再加`$()`的包裹，使用更加简单，例如：

```lua
print(val("host"))
print(val("env PATH"))
local s = val("shell echo hello")
```

而用[vformat](#vformat)就比较繁琐了：

```lua
local s = vformat("$(shell echo hello)")
```

不过`vformat`支持字符串参数格式化，更加强大， 所以应用场景不同。

##### import

###### 导入扩展摸块

import的主要用于导入xmake的扩展类库以及一些自定义的类库模块，一般用于：

* 自定义脚本([on_build](#targeton_build), [on_run](#targeton_run) ..)
* 插件开发
* 模板开发
* 平台扩展
* 自定义任务task

导入机制如下：

1. 优先从当前脚本目录下导入
2. 再从扩展类库中导入

导入的语法规则：

基于`.`的类库路径规则，例如：

导入core核心扩展模块

```lua
import("core.base.option")
import("core.project")
import("core.base.task") -- 2.1.5 以前是 core.project.task
import("core")

function main()
    
    -- 获取参数选项
    print(option.get("version"))

    -- 运行任务和插件
    task.run("hello")
    project.task.run("hello")
    core.base.task.run("hello")
end
```

导入当前目录下的自定义模块：

目录结构：

```
plugin
  - xmake.lua
  - main.lua
  - modules
    - hello1.lua
    - hello2.lua
```

在main.lua中导入modules

```lua
import("modules.hello1")
import("modules.hello2")
```

导入后就可以直接使用里面的所有公有接口，私有接口用`_`前缀标示，表明不会被导出，不会被外部调用到。。

除了当前目录，我们还可以导入其他指定目录里面的类库，例如：

```lua
import("hello3", {rootdir = "/home/xxx/modules"})
```

为了防止命名冲突，导入后还可以指定的别名：

```lua
import("core.platform.platform", {alias = "p"})

function main()
 
    -- 这样我们就可以使用p来调用platform模块的plats接口，获取所有xmake支持的平台列表了
    table.dump(p.plats())
end
```

import不仅可以导入类库，还支持导入的同时作为继承导入，实现模块间的继承关系

```lua
import("xxx.xxx", {inherit = true})
```

这样导入的不是这个模块的引用，而是导入的这个模块的所有公有接口本身，这样就会跟当前模块的接口进行合并，实现模块间的继承。

2.1.5版本新增两个新属性：`import("xxx.xxx", {try = true, anonymous = true})`

try为true，则导入的模块不存在的话，仅仅返回nil，并不会抛异常后中断xmake.
anonymous为true，则导入的模块不会引入当前作用域，仅仅在import接口返回导入的对象引用。

##### inherit

###### 导入并继承基类模块

这个等价于[import](#import)接口的`inherit`模式，也就是：

```lua
import("xxx.xxx", {inherit = true})
```

用`inherit`接口的话，会更简洁些：

```lu
inherit("xxx.xxx")
```

使用实例，可以参看xmake的tools目录下的脚本：[clang.lua](#https://github.com/xmake-io/xmake/blob/master/xmake/tools/clang.lua)

这个就是clang工具模块继承了gcc的部分实现。

##### ifelse

###### 类似三元条件判断

由于lua没有内置的三元运算符，通过封装`ifelse`接口，实现更加简洁的条件选择：

```lua
local ok = ifelse(a == 0, "ok", "no")
```

##### try-catch-finally

###### 异常捕获

lua原生并没有提供try-catch的语法来捕获异常处理，但是提供了`pcall/xpcall`等接口，可在保护模式下执行lua函数。

因此，可以通过封装这两个接口，来实现try-catch块的捕获机制。

我们可以先来看下，封装后的try-catch使用方式：

```lua
try
{
    -- try 代码块
    function ()
        error("error message")
    end,

    -- catch 代码块
    catch 
    {
        -- 发生异常后，被执行
        function (errors)
            print(errors)
        end
    }
}
```

上面的代码中，在try块内部认为引发了一个异常，并且抛出错误消息，在catch中进行了捕获，并且将错误消息进行输出显示。

而finally的处理，这个的作用是对于`try{}`代码块，不管是否执行成功，都会执行到finally块中

也就说，其实上面的实现，完整的支持语法是：`try-catch-finally`模式，其中catch和finally都是可选的，根据自己的实际需求提供

例如：

```lua
try
{
    -- try 代码块
    function ()
        error("error message")
    end,

    -- catch 代码块
    catch 
    {
        -- 发生异常后，被执行
        function (errors)
            print(errors)
        end
    },

    -- finally 代码块
    finally 
    {
        -- 最后都会执行到这里
        function (ok, errors)
            -- 如果try{}中存在异常，ok为true，errors为错误信息，否则为false，errors为try中的返回值
        end
    }
}

```

或者只有finally块：

```lua
try
{
    -- try 代码块
    function ()
        return "info"
    end,

    -- finally 代码块
    finally 
    {
        -- 由于此try代码没发生异常，因此ok为true，errors为返回值: "info"
        function (ok, errors)
        end
    }
}
```

处理可以在finally中获取try里面的正常返回值，其实在仅有try的情况下，也是可以获取返回值的：

```lua
-- 如果没发生异常，result 为返回值："xxxx"，否则为nil
local result = try
{
    function ()
        return "xxxx"
    end
}
```

在xmake的自定义脚本、插件开发中，也是完全基于此异常捕获机制

这样使得扩展脚本的开发非常的精简可读，省去了繁琐的`if err ~= nil then`返回值判断，在发生错误时，xmake会直接抛出异常进行中断，然后高亮提示详细的错误信息。

例如：

```lua
target("test")
    set_kind("binary")
    add_files("src/*.c")

    -- 在编译完ios程序后，对目标程序进行ldid签名
    after_build(function (target))
        os.run("ldid -S %s", target:targetfile())
    end
```

只需要一行`os.run`就行了，也不需要返回值判断是否运行成功，因为运行失败后，xmake会自动抛异常，中断程序并且提示错误

如果你想在运行失败后，不直接中断xmake，继续往下运行，可以自己加个try快就行了：

```lua
target("test")
    set_kind("binary")
    add_files("src/*.c")

    after_build(function (target))
        try
        {
            function ()
                os.run("ldid -S %s", target:targetfile())
            end
        }
    end
```

如果还想捕获出错信息，可以再加个catch:

```lua
target("test")
    set_kind("binary")
    add_files("src/*.c")

    after_build(function (target))
        try
        {
            function ()
                os.run("ldid -S %s", target:targetfile())
            end,
            catch 
            {
                function (errors)
                    print(errors)
                end
            }
        }
    end
```

不过一般情况下，在xmake中写自定义脚本，是不需要手动加try-catch的，直接调用各种api，出错后让xmake默认的处理程序接管，直接中断就行了。。

##### pairs

###### 用于遍历字典

这个是lua原生的内置api，在xmake中，在原有的行为上对其进行了一些扩展，来简化一些日常的lua遍历代码。

先看下默认的原生写法：

```lua
local t = {a = "a", b = "b", c = "c", d = "d", e = "e", f = "f"}

for key, val in pairs(t) do
    print("%s: %s", key, val)
end
```

这对于通常的遍历操作就足够了，但是如果我们相对其中每个遍历出来的元素，获取其大写，我们可以这么写：

```lua
for key, val in pairs(t, function (v) return v:upper() end) do
     print("%s: %s", key, val)
end
```

甚至传入一些参数到第二个`function`中，例如：

```lua
for key, val in pairs(t, function (v, a, b) return v:upper() .. a .. b end, "a", "b") do
     print("%s: %s", key, val)
end
```

##### ipairs

###### 用于遍历数组

这个是lua原生的内置api，在xmake中，在原有的行为上对其进行了一些扩展，来简化一些日常的lua遍历代码。

先看下默认的原生写法：

```lua
for idx, val in ipairs({"a", "b", "c", "d", "e", "f"}) do
     print("%d %s", idx, val)
end
```

扩展写法类似[pairs](#pairs)接口，例如：

```lua
for idx, val in ipairs({"a", "b", "c", "d", "e", "f"}, function (v) return v:upper() end) do
     print("%d %s", idx, val)
end

for idx, val in ipairs({"a", "b", "c", "d", "e", "f"}, function (v, a, b) return v:upper() .. a .. b end, "a", "b") do
     print("%d %s", idx, val)
end
```

这样可以简化`for`块代码的逻辑，例如我要遍历指定目录，获取其中的文件名，但不包括路径，就可以通过这种扩展方式，简化写法：

```lua
for _, filename in ipairs(os.dirs("*"), path.filename) do
    -- ...
end
```

##### print

###### 换行打印终端日志

此接口也是lua的原生接口，xmake在原有行为不变的基础上也进行了扩展，同时支持：格式化输出、多变量输出。

先看下原生支持的方式：

```lua
print("hello xmake!")
print("hello", "xmake!", 123)
```

并且同时还支持扩展的格式化写法：

```lua
print("hello %s!", "xmake")
print("hello xmake! %d", 123)
```

xmake会同时支持这两种写法，内部会去自动智能检测，选择输出行为。

##### printf

###### 无换行打印终端日志

类似[print](#print)接口，唯一的区别就是不换行。

##### cprint

###### 换行彩色打印终端日志

行为类似[print](#print)，区别就是此接口还支持彩色终端输出，并且支持`emoji`字符输出。

例如：

```lua
    cprint('${bright}hello xmake')
    cprint('${red}hello xmake')
    cprint('${bright green}hello ${clear}xmake')
    cprint('${blue onyellow underline}hello xmake${clear}')
    cprint('${red}hello ${magenta}xmake')
    cprint('${cyan}hello ${dim yellow}xmake')
```

显示结果如下：

![cprint_colors](https://tboox.org/static/img/xmake/cprint_colors.png)

跟颜色相关的描述，都放置在 `${  }` 里面，可以同时设置多个不同的属性，例如：

```
    ${bright red underline onyellow}
```

表示：高亮红色，背景黄色，并且带下滑线

所有这些描述，都会影响后面一整行字符，如果只想显示部分颜色的文字，可以在结束位置，插入`${clear}`清楚前面颜色描述

例如：

```
    ${red}hello ${clear}xmake
```

这样的话，仅仅hello是显示红色，其他还是正常默认黑色显示。

其他颜色属于，我这里就不一一介绍，直接贴上xmake代码里面的属性列表吧：

```lua
    colors.keys = 
    {
        -- 属性
        reset       = 0 -- 重置属性
    ,   clear       = 0 -- 清楚属性
    ,   default     = 0 -- 默认属性
    ,   bright      = 1 -- 高亮
    ,   dim         = 2 -- 暗色
    ,   underline   = 4 -- 下划线
    ,   blink       = 5 -- 闪烁
    ,   reverse     = 7 -- 反转颜色
    ,   hidden      = 8 -- 隐藏文字

        -- 前景色 
    ,   black       = 30
    ,   red         = 31
    ,   green       = 32
    ,   yellow      = 33
    ,   blue        = 34
    ,   magenta     = 35 
    ,   cyan        = 36
    ,   white       = 37

        -- 背景色 
    ,   onblack     = 40
    ,   onred       = 41
    ,   ongreen     = 42
    ,   onyellow    = 43
    ,   onblue      = 44
    ,   onmagenta   = 45
    ,   oncyan      = 46
    ,   onwhite     = 47
```

除了可以色彩高亮显示外，如果你的终端是在macosx下，lion以上的系统，xmake还可以支持emoji表情的显示哦，对于不支持系统，会
忽略显示，例如：

```lua
    cprint("hello xmake${beer}")
    cprint("hello${ok_hand} xmake")
```

上面两行代码，我打印了一个homebrew里面经典的啤酒符号，下面那行打印了一个ok的手势符号，是不是很炫哈。。

![cprint_emoji](https://tboox.org/static/img/xmake/cprint_emoji.png)

所有的emoji表情，以及xmake里面对应的key，都可以通过[emoji符号](http://www.emoji-cheat-sheet.com/)里面找到。。

2.1.7版本支持24位真彩色输出，如果终端支持的话：

```lua
import("core.base.colors")
if colors.truecolor() then
    cprint("${255;0;0}hello")
    cprint("${on;255;0;0}hello${clear} xmake")
    cprint("${bright 255;0;0 underline}hello")
    cprint("${bright on;255;0;0 0;255;0}hello${clear} xmake")
end
```

xmake对于truecolor的检测支持，是通过`$COLORTERM`环境变量来实现的，如果你的终端支持truecolor，可以手动设置此环境变量，来告诉xmake启用truecolor支持。

可以通过下面的命令来启用和测试：

```bash
$ export COLORTERM=truecolor
$ xmake --version
```

2.1.7版本可通过`COLORTERM=nocolor`来禁用色彩输出。

##### cprintf

###### 无换行彩色打印终端日志

此接口类似[cprint](#cprint)，区别就是不换行输出。

##### format

###### 格式化字符串

如果只是想格式化字符串，不进行输出，可以使用这个接口，此接口跟[string.format](#string-format)接口等价，只是个接口名简化版。

```lua
local s = format("hello %s", xmake)
```

##### vformat

###### 格式化字符串，支持内置变量转义

此接口跟[format](#format)接口类似，只是增加对内置变量的获取和转义支持。

```lua
local s = vformat("hello %s $(mode) $(arch) $(env PATH)", xmake)
```

##### raise

###### 抛出异常中断程序

如果想在自定义脚本、插件任务中中断xmake运行，可以使用这个接口抛出异常，如果上层没有显示调用[try-catch](#try-catch-finally)捕获的话，xmake就会中断执行，并且显示出错信息。

```lua
if (errors) raise(errors)
```

如果在try块中抛出异常，就会在catch和finally中进行errors信息捕获，具体见：[try-catch](#try-catch-finally)

##### find_packages

###### 查找依赖包

此接口是对[lib.detect.find_package](#detect-find_package)接口的封装，提供多个依赖包的查找支持，例如：

```lua
target("test")
    set_kind("binary")
    add_files("src/*.c")
    on_load(function (target)
        target:add(find_packages("openssl", "zlib"))
    end)
```

##### os

系统操作模块，属于内置模块，无需使用[import](#import)导入，可直接脚本域调用其接口。

此模块也是lua的原生模块，xmake在其基础上进行了扩展，提供更多实用的接口。

<p class="tips">
os模块里面只有部分readonly接口（例如：`os.getenv`, `os.arch`）是可以在描述域中使用，其他接口只能在脚本域中使用，例如：`os.cp`, `os.rm`等
</p>

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [os.cp](#os-cp)                                 | 复制文件或目录                               | >= 2.0.1 |
| [os.mv](#os-mv)                                 | 移动重命名文件或目录                         | >= 2.0.1 |
| [os.rm](#os-rm)                                 | 删除文件或目录树                             | >= 2.0.1 |
| [os.trycp](#os-trycp)                           | 尝试复制文件或目录                           | >= 2.1.6 |
| [os.trymv](#os-trymv)                           | 尝试移动重命名文件或目录                     | >= 2.1.6 |
| [os.tryrm](#os-tryrm)                           | 尝试删除文件或目录树                         | >= 2.1.6 |
| [os.cd](#os-cd)                                 | 进入指定目录                                 | >= 2.0.1 |
| [os.rmdir](#os-rmdir)                           | 删除目录树                                   | >= 2.0.1 |
| [os.mkdir](#os-mkdir)                           | 创建指定目录                                 | >= 2.0.1 |
| [os.isdir](#os-isdir)                           | 判断目录是否存在                             | >= 2.0.1 |
| [os.isfile](#os-isfile)                         | 判断文件是否存在                             | >= 2.0.1 |
| [os.exists](#os-exists)                         | 判断文件或目录是否存在                       | >= 2.0.1 |
| [os.dirs](#os-dirs)                             | 遍历获取指定目录下的所有目录                 | >= 2.0.1 |
| [os.files](#os-files)                           | 遍历获取指定目录下的所有文件                 | >= 2.0.1 |
| [os.filedirs](#os-filedirs)                     | 遍历获取指定目录下的所有文件或目录           | >= 2.0.1 |
| [os.run](#os-run)                               | 安静运行程序                                 | >= 2.0.1 |
| [os.runv](#os-runv)                             | 安静运行程序，带参数列表                     | >= 2.1.5 |
| [os.exec](#os-exec)                             | 回显运行程序                                 | >= 2.0.1 |
| [os.execv](#os-execv)                           | 回显运行程序，带参数列表                     | >= 2.1.5 |
| [os.iorun](#os-iorun)                           | 运行并获取程序输出内容                       | >= 2.0.1 |
| [os.iorunv](#os-iorunv)                         | 运行并获取程序输出内容，带参数列表           | >= 2.1.5 |
| [os.getenv](#os-getenv)                         | 获取环境变量                                 | >= 2.0.1 |
| [os.setenv](#os-setenv)                         | 设置环境变量                                 | >= 2.0.1 |
| [os.tmpdir](#os-tmpdir)                         | 获取临时目录路径                             | >= 2.0.1 |
| [os.tmpfile](#os-tmpfile)                       | 获取临时文件路径                             | >= 2.0.1 |
| [os.curdir](#os-curdir)                         | 获取当前目录路径                             | >= 2.0.1 |
| [os.filesize](#os-filesize)                     | 获取文件大小                                 | >= 2.1.9 |
| [os.scriptdir](#os-scriptdir)                   | 获取脚本目录路径                             | >= 2.0.1 |
| [os.programdir](#os-programdir)                 | 获取xmake安装主程序脚本目录                  | >= 2.1.5 |
| [os.projectdir](#os-projectdir)                 | 获取工程主目录                               | >= 2.1.5 |
| [os.arch](#os-arch)                             | 获取当前系统架构                             | >= 2.0.1 |
| [os.host](#os-host)                             | 获取当前主机系统                             | >= 2.0.1 |

###### os.cp

- 复制文件或目录

行为和shell中的`cp`命令类似，支持路径通配符匹配（使用的是lua模式匹配），支持多文件复制，以及内置变量支持。

例如：

```lua
os.cp("$(scriptdir)/*.h", "$(projectdir)/src/test/**.h", "$(buildir)/inc")
```

上面的代码将：当前`xmake.lua`目录下的所有头文件、工程源码test目录下的头文件全部复制到`$(buildir)`输出目录中。

其中`$(scriptdir)`, `$(projectdir)` 这些变量是xmake的内置变量，具体详情见：[内置变量](#内置变量)的相关文档。

而`*.h`和`**.h`中的匹配模式，跟[add_files](#targetadd_files)中的类似，前者是单级目录匹配，后者是递归多级目录匹配。

此接口同时支持目录的`递归复制`，例如：

```lua
-- 递归复制当前目录到临时目录
os.cp("$(curdir)/test/", "$(tmpdir)/test")
```

<p class="tip">
尽量使用`os.cp`接口，而不是`os.run("cp ..")`，这样更能保证平台一致性，实现跨平台构建描述。
</p>

###### os.mv

- 移动重命名文件或目录

跟[os.cp](#os-cp)的使用类似，同样支持多文件移动操作和模式匹配，例如：

```lua
-- 移动多个文件到临时目录
os.mv("$(buildir)/test1", "$(buildir)/test2", "$(tmpdir)")

-- 文件移动不支持批量操作，也就是文件重命名
os.mv("$(buildir)/libtest.a", "$(buildir)/libdemo.a")
```

###### os.rm

- 删除文件或目录树

支持递归删除目录，批量删除操作，以及模式匹配和内置变量，例如：

```lua
os.rm("$(buildir)/inc/**.h", "$(buildir)/lib/")
```

###### os.trycp

- 尝试复制文件或目录

跟[os.cp](#os-cp)类似，唯一的区别就是，此接口操作失败不会抛出异常中断xmake，而是通过返回值标示是否执行成功。

```lua
if os.trycp("file", "dest/file") then
end
```

###### os.trymv

- 尝试移动文件或目录

跟[os.mv](#os-mv)类似，唯一的区别就是，此接口操作失败不会抛出异常中断xmake，而是通过返回值标示是否执行成功。

```lua
if os.trymv("file", "dest/file") then
end
```

###### os.tryrm

- 尝试删除文件或目录

跟[os.rm](#os-rm)类似，唯一的区别就是，此接口操作失败不会抛出异常中断xmake，而是通过返回值标示是否执行成功。

```lua
if os.tryrm("file") then
end
```

###### os.cd

- 进入指定目录

这个操作用于目录切换，同样也支持内置变量，但是不支持模式匹配和多目录处理，例如：

```lua
-- 进入临时目录
os.cd("$(tmpdir)")
```

如果要离开进入之前的目录，有多种方式：

```lua
-- 进入上级目录
os.cd("..")

-- 进入先前的目录，相当于：cd -
os.cd("-")

-- 进入目录前保存之前的目录，用于之后跨级直接切回
local oldir = os.cd("./src")
...
os.cd(oldir)
```

###### os.rmdir

- 仅删除目录

如果不是目录就无法删除。

###### os.mkdir

- 创建目录

支持批量创建和内置变量，例如：

```lua
os.mkdir("$(tmpdir)/test", "$(buildir)/inc")
```

###### os.isdir

- 判断是否为目录

如果目录不存在，则返回false

```lua
if os.isdir("src") then
    -- ...
end
```

###### os.isfile

- 判断是否为文件

如果文件不存在，则返回false

```lua
if os.isfile("$(buildir)/libxxx.a") then
    -- ...
end
```

###### os.exists

- 判断文件或目录是否存在

如果文件或目录不存在，则返回false

```lua
-- 判断目录存在
if os.exists("$(buildir)") then
    -- ...
end

-- 判断文件存在
if os.exists("$(buildir)/libxxx.a") then
    -- ...
end
```

###### os.dirs

- 遍历获取指定目录下的所有目录

支持[add_files](#targetadd_files)中的模式匹配，支持递归和非递归模式遍历，返回的结果是一个table数组，如果获取不到，返回空数组，例如：

```lua
-- 递归遍历获取所有子目录
for _, dir in ipairs(os.dirs("$(buildir)/inc/**")) do
    print(dir)
end
```

###### os.files

- 遍历获取指定目录下的所有文件

支持[add_files](#targetadd_files)中的模式匹配，支持递归和非递归模式遍历，返回的结果是一个table数组，如果获取不到，返回空数组，例如：

```lua
-- 非递归遍历获取所有子文件
for _, filepath in ipairs(os.files("$(buildir)/inc/*.h")) do
    print(filepath)
end
```

###### os.filedirs

- 遍历获取指定目录下的所有文件和目录

支持[add_files](#targetadd_files)中的模式匹配，支持递归和非递归模式遍历，返回的结果是一个table数组，如果获取不到，返回空数组，例如：

```lua
-- 递归遍历获取所有子文件和目录
for _, filedir in ipairs(os.filedirs("$(buildir)/**")) do
    print(filedir)
end
```

###### os.run

- 安静运行原生shell命令

用于执行第三方的shell命令，但不会回显输出，仅仅在出错后，高亮输出错误信息。

此接口支持参数格式化、内置变量，例如：

```lua
-- 格式化参数传入
os.run("echo hello %s!", "xmake")

-- 列举构建目录文件
os.run("ls -l $(buildir)")
```

<p class="warning">
使用此接口执行shell命令，容易使构建跨平台性降低，对于`os.run("cp ..")`这种尽量使用`os.cp`代替。<br>
如果必须使用此接口运行shell程序，请自行使用[config.plat](#config-plat)接口判断平台支持。
</p>

更加高级的进程运行和控制，见[process](#process)模块接口。

###### os.runv

- 安静运行原生shell命令，带参数列表

跟[os.run](#os-run)类似，只是传递参数的方式是通过参数列表传递，而不是字符串命令，例如：

```lua
os.runv("echo", {"hello", "xmake!"})
```

###### os.exec

- 回显运行原生shell命令

与[os.run](#os-run)接口类似，唯一的不同是，此接口执行shell程序时，是带回显输出的，一般调试的时候用的比较多

###### os.execv

- 回显运行原生shell命令，带参数列表

跟[os.execv](#os-execv)类似，只是传递参数的方式是通过参数列表传递，而不是字符串命令，例如：

```lua
os.execv("echo", {"hello", "xmake!"})
```

###### os.iorun

- 安静运行原生shell命令并获取输出内容

与[os.run](#os-run)接口类似，唯一的不同是，此接口执行shell程序后，会获取shell程序的执行结果，相当于重定向输出。

可同时获取`stdout`, `stderr`中的内容，例如：

```lua
local outdata, errdata = os.iorun("echo hello xmake!")
```

###### os.iorunv

- 安静运行原生shell命令并获取输出内容，带参数列表

跟[os.iorunv](#os-iorunv)类似，只是传递参数的方式是通过参数列表传递，而不是字符串命令，例如：

```lua
local result, errors = os.iorunv("echo", {"hello", "xmake!"})
```

###### os.getenv

- 获取系统环境变量

```lua
print(os.getenv("PATH"))
```

###### os.setenv

- 设置系统环境变量

```lua
os.setenv("HOME", "/tmp/")
```

###### os.tmpdir

- 获取临时目录

跟[$(tmpdir)](#var-tmpdir)结果一致，只不过是直接获取返回一个变量，可以用后续字符串维护。

```lua
print(path.join(os.tmpdir(), "file.txt"))
```

等价于：

```lua
print("$(tmpdir)/file.txt"))
```

###### os.tmpfile

- 获取临时文件路径

用于获取生成一个临时文件路径，仅仅是个路径，文件需要自己创建。

###### os.curdir

- 获取当前目录路径

跟[$(curdir)](#var-curdir)结果一致，只不过是直接获取返回一个变量，可以用后续字符串维护。

用法参考：[os.tmpdir](#os-tmpdir)。

###### os.filesize

- 获取文件大小

```lua
print(os.filesize("/tmp/a"))
```

###### os.scriptdir

- 获取当前描述脚本的路径

跟[$(scriptdir)](#var-scriptdir)结果一致，只不过是直接获取返回一个变量，可以用后续字符串维护。

用法参考：[os.tmpdir](#os-tmpdir)。

###### os.programdir

- 获取xmake安装主程序脚本目录

跟[$(programdir)](#var-programdir)结果一致，只不过是直接获取返回一个变量，可以用后续字符串维护。

###### os.projectdir

- 获取工程主目录

跟[$(projectdir)](#var-projectdir)结果一致，只不过是直接获取返回一个变量，可以用后续字符串维护。

###### os.arch

- 获取当前系统架构

也就是当前主机系统的默认架构，例如我在`linux x86_64`上执行xmake进行构建，那么返回值是：`x86_64`

###### os.host

- 获取当前主机的操作系统

跟[$(host)](#var-host)结果一致，例如我在`linux x86_64`上执行xmake进行构建，那么返回值是：`linux`

##### io

io操作模块，扩展了lua内置的io模块，提供更多易用的接口。

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [io.open](#io-open)                             | 打开文件用于读写                             | >= 2.0.1 |
| [io.load](#io-load)                             | 从指定路径文件反序列化加载所有table内容      | >= 2.0.1 |
| [io.save](#io-save)                             | 序列化保存所有table内容到指定路径文件        | >= 2.0.1 |
| [io.readfile](#io.readfile)                     | 从指定路径文件读取所有内容                   | >= 2.1.3 |
| [io.writefile](#io.writefile)                   | 写入所有内容到指定路径文件                   | >= 2.1.3 |
| [io.gsub](#io-gsub)                             | 全文替换指定路径文件的内容                   | >= 2.0.1 |
| [io.tail](#io-tail)                             | 读取和显示文件的尾部内容                     | >= 2.0.1 |
| [io.cat](#io-cat)                               | 读取和显示文件的所有内容                     | >= 2.0.1 |
| [io.print](#io-print)                           | 带换行格式化输出内容到文件                   | >= 2.0.1 |
| [io.printf](#io-printf)                         | 无换行格式化输出内容到文件                   | >= 2.0.1 |

###### io.open

- 打开文件用于读写

这个是属于lua的原生接口，详细使用可以参看lua的官方文档：[The Complete I/O Model](https://www.lua.org/pil/21.2.html)

如果要读取文件所有内容，可以这么写：

```lua
local file = io.open("$(tmpdir)/file.txt", "r")
if file then
    local data = file:read("*all")
    file:close()
end
```

或者可以使用[io.readfile](#io.readfile)更加快速地读取。

如果要写文件，可以这么操作：

```lua
-- 打开文件：w 为写模式, a 为追加写模式
local file = io.open("xxx.txt", "w")
if file then

    -- 用原生的lua接口写入数据到文件，不支持格式化，无换行，不支持内置变量
    file:write("hello xmake\n")

    -- 用xmake扩展的接口写入数据到文件，支持格式化，无换行，不支持内置变量
    file:writef("hello %s\n", "xmake")

    -- 使用xmake扩展的格式化传参写入一行，带换行符，并且支持内置变量
    file:print("hello %s and $(buildir)", "xmake")

    -- 使用xmake扩展的格式化传参写入一行，无换行符，并且支持内置变量
    file:printf("hello %s and $(buildir) \n", "xmake")

    -- 关闭文件
    file:close()
end
```

###### io.load

-  从指定路径文件反序列化加载所有table内容

可以从文件中加载序列化好的table内容，一般与[io.save](#io-save)配合使用，例如：

```lua
-- 加载序列化文件的内容到table
local data = io.load("xxx.txt")
if data then

    -- 在终端中dump打印整个table中内容，格式化输出
    table.dump(data)
end
```

###### io.save

- 序列化保存所有table内容到指定路径文件 

可以序列化存储table内容到指定文件，一般与[io.load](#io-load)配合使用，例如：

```lua
io.save("xxx.txt", {a = "a", b = "b", c = "c"})
```

存储结果为：

```
{
    ["b"] = "b"
,   ["a"] = "a"
,   ["c"] = "c"
}
```

###### io.readfile

- 从指定路径文件读取所有内容

可在不打开文件的情况下，直接读取整个文件的内容，更加的方便，例如：

```lua
local data = io.readfile("xxx.txt")
```

###### io.writefile

- 写入所有内容到指定路径文件

可在不打开文件的情况下，直接写入整个文件的内容，更加的方便，例如：

```lua
io.writefile("xxx.txt", "all data")
```

###### io.gsub

- 全文替换指定路径文件的内容

类似[string.gsub](#string-gsub)接口，全文模式匹配替换内容，不过这里是直接操作文件，例如：

```lua
-- 移除文件所有的空白字符
io.gsub("xxx.txt", "%s+", "")
```

###### io.tail

- 读取和显示文件的尾部内容

读取文件尾部指定行数的数据，并显示，类似`cat xxx.txt | tail -n 10`命令，例如：

```lua
-- 显示文件最后10行内容
io.tail("xxx.txt", 10)
```

###### io.cat

- 读取和显示文件的所有内容

读取文件的所有内容并显示，类似`cat xxx.txt`命令，例如：

```lua
io.cat("xxx.txt")
```

###### io.print

- 带换行格式化输出内容到文件

直接格式化传参输出一行字符串到文件，并且带换行，例如：

```lua
io.print("xxx.txt", "hello %s!", "xmake")
```

###### io.printf

- 无换行格式化输出内容到文件

直接格式化传参输出一行字符串到文件，不带换行，例如：

```lua
io.printf("xxx.txt", "hello %s!\n", "xmake")
```

##### path

路径操作模块，实现跨平台的路径操作，这是xmake的一个自定义的模块。

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [path.join](#path-join)                         | 拼接路径                                     | >= 2.0.1 |
| [path.translate](#path-translate)               | 转换路径到当前平台的路径风格                 | >= 2.0.1 |
| [path.basename](#path-basename)                 | 获取路径最后不带后缀的文件名                 | >= 2.0.1 |
| [path.filename](#path-filename)                 | 获取路径最后带后缀的文件名                   | >= 2.0.1 |
| [path.extension](#path-extension)               | 获取路径的后缀名                             | >= 2.0.1 |
| [path.directory](#path-directory)               | 获取路径最后的目录名                         | >= 2.0.1 |
| [path.relative](#path-relative)                 | 转换成相对路径                               | >= 2.0.1 |
| [path.absolute](#path-absolute)                 | 转换成绝对路径                               | >= 2.0.1 |
| [path.is_absolute](#path-is_absolute)           | 判断是否为绝对路径                           | >= 2.0.1 |

###### path.join

- 拼接路径

将多个路径项进行追加拼接，由于`windows/unix`风格的路径差异，使用api来追加路径更加跨平台，例如：

```lua
print(path.join("$(tmpdir)", "dir1", "dir2", "file.txt"))
```

上述拼接在unix上相当于：`$(tmpdir)/dir1/dir2/file.txt`，而在windows上相当于：`$(tmpdir)\\dir1\\dir2\\file.txt`

如果觉得这样很繁琐，不够清晰简洁，可以使用：[path.translate](path-translate)方式，格式化转换路径字符串到当前平台支持的格式。

###### path.translate

- 转换路径到当前平台的路径风格

格式化转化指定路径字符串到当前平台支持的路径风格，同时支持`windows/unix`格式的路径字符串参数传入，甚至混合传入，例如：

```lua
print(path.translate("$(tmpdir)/dir/file.txt"))
print(path.translate("$(tmpdir)\\dir\\file.txt"))
print(path.translate("$(tmpdir)\\dir/dir2//file.txt"))
```

上面这三种不同格式的路径字符串，经过`translate`规范化后，就会变成当前平台支持的格式，并且会去掉冗余的路径分隔符。

###### path.basename

- 获取路径最后不带后缀的文件名

```lua
print(path.basename("$(tmpdir)/dir/file.txt"))
```

显示结果为：`file`

###### path.filename

- 获取路径最后带后缀的文件名

```lua
print(path.filename("$(tmpdir)/dir/file.txt"))
```

显示结果为：`file.txt`

###### path.extension

- 获取路径的后缀名

```lua
print(path.extensione("$(tmpdir)/dir/file.txt"))
```

显示结果为：`.txt`

###### path.directory

- 获取路径最后的目录名

```lua
print(path.directory("$(tmpdir)/dir/file.txt"))
```

显示结果为：`dir`

###### path.relative

- 转换成相对路径

```lua
print(path.relative("$(tmpdir)/dir/file.txt", "$(tmpdir)"))
```

显示结果为：`dir/file.txt`

第二个参数是指定相对的根目录，如果不指定，则默认相对当前目录：

```lua
os.cd("$(tmpdir)")
print(path.relative("$(tmpdir)/dir/file.txt"))
```

这样结果是一样的。

###### path.absolute

- 转换成绝对路径

```lua
print(path.absolute("dir/file.txt", "$(tmpdir)"))
```

显示结果为：`$(tmpdir)/dir/file.txt`

第二个参数是指定相对的根目录，如果不指定，则默认相对当前目录：

```lua
os.cd("$(tmpdir)")
print(path.absolute("dir/file.txt"))
```

这样结果是一样的。

###### path.is_absolute

- 判断是否为绝对路径

```lua
if path.is_absolute("/tmp/file.txt") then
    -- 如果是绝对路径
end
```

##### table

table属于lua原生提供的模块，对于原生接口使用可以参考：[lua官方文档](https://www.lua.org/manual/5.1/manual.html#5.5)

xmake中对其进行了扩展，增加了一些扩展接口：

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [table.join](#table-join)                       | 合并多个table并返回                          | >= 2.0.1 |
| [table.join2](#table-join2)                     | 合并多个table到第一个table                   | >= 2.0.1 |
| [table.dump](#table-dump)                       | 输出table的所有内容                          | >= 2.0.1 |
| [table.unique](#table-unique)                   | 对table中的内容进行去重                      | >= 2.0.1 |
| [table.slice](#table-slice)                     | 获取table的切片                              | >= 2.0.1 |

###### table.join

- 合并多个table并返回

可以将多个table里面的元素进行合并后，返回到一个新的table中，例如：

```lua
local newtable = table.join({1, 2, 3}, {4, 5, 6}, {7, 8, 9})
```

结果为：`{1, 2, 3, 4, 5, 6, 7, 8, 9}`

并且它也支持字典的合并：

```lua
local newtable = table.join({a = "a", b = "b"}, {c = "c"}, {d = "d"})
```

结果为：`{a = "a", b = "b", c = "c", d = "d"}`

###### table.join2

- 合并多个table到第一个table

类似[table.join](#table.join)，唯一的区别是，合并的结果放置在第一个参数中，例如：

```lua
local t = {0, 9}
table.join2(t, {1, 2, 3})
```

结果为：`t = {0, 9, 1, 2, 3}`

###### table.dump

- 输出table的所有内容 

递归格式化打印table中的所有内容，一般用于调试， 例如：

```lua
table.dump({1, 2, 3})
```

结果为：`{1, 2, 3}`

###### table.unique

- 对table中的内容进行去重

去重table的元素，一般用于数组table，例如：

```lua
local newtable = table.unique({1, 1, 2, 3, 4, 4, 5})
```

结果为：`{1, 2, 3, 4, 5}`

###### table.slice

- 获取table的切片

用于提取数组table的部分元素，例如：

```lua
-- 提取第4个元素后面的所有元素，结果：{4, 5, 6, 7, 8, 9}
table.slice({1, 2, 3, 4, 5, 6, 7, 8, 9}, 4)

-- 提取第4-8个元素，结果：{4, 5, 6, 7, 8}
table.slice({1, 2, 3, 4, 5, 6, 7, 8, 9}, 4, 8)

-- 提取第4-8个元素，间隔步长为2，结果：{4, 6, 8}
table.slice({1, 2, 3, 4, 5, 6, 7, 8, 9}, 4, 8, 2)
```

##### string

字符串模块为lua原生自带的模块，具体使用见：[lua官方手册](https://www.lua.org/manual/5.1/manual.html#5.4)

xmake中对其进行了扩展，增加了一些扩展接口：

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [string.startswith](#string-startswith)         | 判断字符串开头是否匹配                       | >= 1.0.1 |
| [string.endswith](#string-endswith)             | 判断字符串结尾是否匹配                       | >= 1.0.1 |
| [string.split](#string-split)                   | 分割字符串                                   | >= 1.0.1 |
| [string.trim](#string-trim)                     | 去掉字符串左右空白字符                       | >= 1.0.1 |
| [string.ltrim](#string-ltrim)                   | 去掉字符串左边空白字符                       | >= 1.0.1 |
| [string.rtrim](#string-rtrim)                   | 去掉字符串右边空白字符                       | >= 1.0.1 |

###### string.startswith

- 判断字符串开头是否匹配

```lua
local s = "hello xmake"
if s:startswith("hello") then
    print("match")
end
```

###### string.endswith

- 判断字符串结尾是否匹配

```lua
local s = "hello xmake"
if s:endswith("xmake") then
    print("match")
end
```

###### string.split

- 分割字符串

v2.2.7版本对这个接口做了改进，以下是对2.2.7之后版本的使用说明。

按模式匹配分割字符串，忽略空串，例如：

```lua
("1\n\n2\n3"):split('\n') => 1, 2, 3
("abc123123xyz123abc"):split('123') => abc, xyz, abc
("abc123123xyz123abc"):split('[123]+') => abc, xyz, abc
```

按纯文本匹配分割字符串，忽略空串（省去了模式匹配，会提升稍许性能），例如：

```lua
("1\n\n2\n3"):split('\n', {plain = true}) => 1, 2, 3
("abc123123xyz123abc"):split('123', {plain = true}) => abc, xyz, abc
```

按模式匹配分割字符串，严格匹配，不忽略空串，例如：

```lua
("1\n\n2\n3"):split('\n', {strict = true}) => 1, , 2, 3
("abc123123xyz123abc"):split('123', {strict = true}) => abc, , xyz, abc
("abc123123xyz123abc"):split('[123]+', {strict = true}) => abc, xyz, abc
```

按纯文本匹配分割字符串，严格匹配，不忽略空串（省去了模式匹配，会提升稍许性能），例如：

```lua
("1\n\n2\n3"):split('\n', {plain = true, strict = true}) => 1, , 2, 3
("abc123123xyz123abc"):split('123', {plain = true, strict = true}) => abc, , xyz, abc
```

限制分割块数

```lua
("1\n\n2\n3"):split('\n', {limit = 2}) => 1, 2\n3
("1.2.3.4.5"):split('%.', {limit = 3}) => 1, 2, 3.4.5
```

###### string.trim

- 去掉字符串左右空白字符

```lua
string.trim("    hello xmake!    ")
```

结果为："hello xmake!"

###### string.ltrim

- 去掉字符串左边空白字符

```lua
string.ltrim("    hello xmake!    ")
```

结果为："hello xmake!    "

###### string.rtrim

- 去掉字符串右边空白字符

```lua
string.rtrim("    hello xmake!    ")
```

结果为："    hello xmake!"

##### process

这个是xmake扩展的进程控制模块，用于更加灵活的控制进程，比起：[os.run](#os-run)系列灵活性更高，也更底层。

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [process.open](#process-open)                   | 打开进程                                     | >= 2.0.1 |
| [process.wait](#process-wait)                   | 等待进程结束                                 | >= 2.0.1 |
| [process.close](#process-close)                 | 关闭进程对象                                 | >= 2.0.1 |
| [process.waitlist](#process-waitlist)           | 同时等待多个进程                             | >= 2.0.1 |

###### process.open

- 打开进程

通过路径创建运行一个指定程序，并且返回对应的进程对象：

```lua
-- 打开进程，后面两个参数指定需要捕获的stdout, stderr文件路径
local proc = process.open("echo hello xmake!", outfile, errfile)
if proc then

    -- 等待进程执行完成
    --
    -- 参数二为等待超时，-1为永久等待，0为尝试获取进程状态
    -- 返回值waitok为等待状态：1为等待进程正常结束，0为进程还在运行中，-1位等待失败
    -- 返回值status为，等待进程结束后，进程返回的状态码
    local waitok, status = process.wait(proc, -1)

    -- 释放进程对象
    process.close(proc)
end
```

###### process.wait

- 等待进程结束

具体使用见：[process.open](#process-open)

###### process.close

- 关闭进程对象

具体使用见：[process.open](#process-open)

###### process.waitlist

- 同时等待多个进程

```lua
-- 第二个参数是等待超时，返回进程状态列表
for _, procinfo in ipairs(process.waitlist(procs, -1)) do
    
    -- 每个进程的：进程对象、进程pid、进程结束状态码
    local proc      = procinfo[1]
    local procid    = procinfo[2]
    local status    = procinfo[3]

end
```

##### coroutine

协程模块是lua原生自带的模块，具使用见：[lua官方手册](https://www.lua.org/manual/5.1/manual.html#5.2)

#### 扩展模块

所有扩展模块的使用，都需要通过[import](#import)接口，进行导入后才能使用。

##### core.base.option

一般用于获取xmake命令参数选项的值，常用于插件开发。

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [option.get](#option-get)                       | 获取参数选项值                               | >= 2.0.1 |

###### option.get

- 获取参数选项值

在插件开发中用于获取参数选项值，例如：

```lua
-- 导入选项模块
import("core.base.option")

-- 插件入口函数
function main(...)
    print(option.get("info"))
end
```

上面的代码获取hello插件，执行：`xmake hello --info=xxxx` 命令时候传入的`--info=`选项的值，并显示：`xxxx`

对于非main入口的task任务或插件，可以这么使用：

```lua
task("hello")
    on_run(function ())
        import("core.base.option")
        print(option.get("info"))
    end)
```

##### core.base.global

用于获取xmake全局的配置信息，也就是`xmake g|global --xxx=val` 传入的参数选项值。

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [global.get](#global-get)                       | 获取指定配置值                               | >= 2.0.1 |
| [global.load](#global-load)                     | 加载配置                                     | >= 2.0.1 |
| [global.directory](#global-directory)           | 获取全局配置信息目录                         | >= 2.0.1 |
| [global.dump](#global-dump)                     | 打印输出所有全局配置信息                     | >= 2.0.1 |

<p class="tip">
2.1.5版本之前为`core.project.global`。
</p>

###### global.get

- 获取指定配置值

类似[config.get](#config-get)，唯一的区别就是这个是从全局配置中获取。

###### global.load

- 加载配置

类似[global.get](#global-get)，唯一的区别就是这个是从全局配置中加载。

###### global.directory

- 获取全局配置信息目录

默认为`~/.config`目录。

###### global.dump

- 打印输出所有全局配置信息

输出结果如下：

```lua
{
    clean = true
,   ccache = "ccache"
,   xcode_dir = "/Applications/Xcode.app"
}
```

##### core.base.task

用于任务操作，一般用于在自定义脚本中、插件任务中，调用运行其他task任务。

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [task.run](#task-run)                           | 运行指定任务                                 | >= 2.0.1 |

<p class="tip">
2.1.5版本之前为`core.project.task`。
</p>

###### task.run

- 运行指定任务

用于在自定义脚本、插件任务中运行[task](#task)定义的任务或插件，例如：

```lua
task("hello")
    on_run(function ()
        print("hello xmake!")
    end)

target("demo")
    on_clean(function(target)

        -- 导入task模块
        import("core.base.task")

        -- 运行这个hello task
        task.run("hello")
    end)
```

我们还可以在运行任务时，增加参数传递，例如：

```lua
task("hello")
    on_run(function (arg1, arg2)
        print("hello xmake: %s %s!", arg1, arg2)
    end)

target("demo")
    on_clean(function(target)

        -- 导入task
        import("core.base.task")

        -- {} 这个是给第一种选项传参使用，这里置空，这里在最后面传入了两个参数：arg1, arg2
        task.run("hello", {}, "arg1", "arg2")
    end)
```

对于`task.run`的第二个参数，用于传递命令行菜单中的选项，而不是直接传入`function (arg, ...)`函数入口中，例如：

```lua
-- 导入task
import("core.base.task")

-- 插件入口
function main(...)

    -- 运行内置的xmake配置任务，相当于：xmake f|config --plat=iphoneos --arch=armv7
    task.run("config", {plat="iphoneos", arch="armv7"})
emd
```

##### core.tool.linker

链接器相关操作，常用于插件开发。

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [linker.link](#linker-link)                     | 执行链接                                     | >= 2.0.1 |
| [linker.linkcmd](#linker-linkcmd)               | 获取链接命令行                               | >= 2.0.1 |
| [linker.linkargv](#linker-linkargv)             | 获取链接命令行列表                           | >= 2.1.5 |
| [linker.linkflags](#linker-linkflags)           | 获取链接选项                                 | >= 2.0.1 |
| [linker.has_flags](#linker-has_flags)           | 判断指定链接选项是否支持                     | >= 2.1.5 |

###### linker.link

- 执行链接

针对target，链接指定对象文件列表，生成对应的目标文件，例如：

```lua
linker.link("binary", "cc", {"a.o", "b.o", "c.o"}, target:targetfile(), {target = target})
```

其中[target](#target)，为工程目标，这里传入，主要用于获取target特定的链接选项，具体如果获取工程目标对象，见：[core.project.project](#core-project-project)

当然也可以不指定target，例如：

```lua
linker.link("binary", "cc", {"a.o", "b.o", "c.o"}, "/tmp/targetfile")
```

第一个参数指定链接类型，目前支持：binary, static, shared
第二个参数告诉链接器，应该作为那种源文件对象进行链接，这些对象源文件使用什么编译器编译的，例如：

| 第二个参数值 | 描述         |
| ------------ | ------------ |
| cc           | c编译器      |
| cxx          | c++编译器    |
| mm           | objc编译器   |
| mxx          | objc++编译器 |
| gc           | go编译器     |
| as           | 汇编器       |
| sc           | swift编译器  |
| rc           | rust编译器   |
| dc           | dlang编译器  |

指定不同的编译器类型，链接器会适配最合适的链接器来处理链接，并且如果几种支持混合编译的语言，那么可以同时传入多个编译器类型，指定链接器选择支持这些混合编译语言的链接器进行链接处理：

```lua
linker.link("binary", {"cc", "mxx", "sc"}, {"a.o", "b.o", "c.o"}, "/tmp/targetfile")
```

上述代码告诉链接器，a, b, c三个对象文件有可能分别是c, objc++, swift代码编译出来的，链接器会从当前系统和工具链中选择最合适的链接器去处理这个链接过程。

###### linker.linkcmd

- 获取链接命令行字符串

直接获取[linker.link](#linker-link)中执行的命令行字符串，相当于：

```lua
local cmdstr = linker.linkcmd("static", "cxx", {"a.o", "b.o", "c.o"}, target:targetfile(), {target = target})
```

注：后面`{target = target}`扩展参数部分是可选的，如果传递了target对象，那么生成的链接命令，会加上这个target配置对应的链接选项。

并且还可以自己传递各种配置，例如：

```lua
local cmdstr = linker.linkcmd("static", "cxx", {"a.o", "b.o", "c.o"}, target:targetfile(), {config = {linkdirs = "/usr/lib"}})
```

###### linker.linkargv

- 获取链接命令行参数列表

跟[linker.linkcmd](#linker-linkcmd)稍微有点区别的是，此接口返回的是参数列表，table表示，更加方便操作：

```lua
local program, argv = linker.linkargv("static", "cxx", {"a.o", "b.o", "c.o"}, target:targetfile(), {target = target})
```

其中返回的第一个值是主程序名，后面是参数列表，而`os.args(table.join(program, argv))`等价于`linker.linkcmd`。

我们也可以通过传入返回值给[os.runv](#os-runv)来直接运行它：`os.runv(linker.linkargv(..))`

###### linker.linkflags

- 获取链接选项

获取[linker.linkcmd](#linker-linkcmd)中的链接选项字符串部分，不带shellname和对象文件列表，并且是按数组返回，例如：

```lua
local flags = linker.linkflags("shared", "cc", {target = target})
for _, flag in ipairs(flags) do
    print(flag)
end
```

返回的是flags的列表数组。

###### linker.has_flags

- 判断指定链接选项是否支持

虽然通过[lib.detect.has_flags](detect-has_flags)也能判断，但是那个接口更加底层，需要指定链接器名称
而此接口只需要指定target的目标类型，源文件类型，它会自动切换选择当前支持的链接器。

```lua
if linker.has_flags(target:targetkind(), target:sourcekinds(), "-L/usr/lib -lpthread") then
    -- ok
end
```

##### core.tool.compiler

编译器相关操作，常用于插件开发。

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [compiler.compile](#compiler-compile)           | 执行编译                                     | >= 2.0.1 |
| [compiler.compcmd](#compiler-compcmd)           | 获取编译命令行                               | >= 2.0.1 |
| [compiler.compargv](#compiler-compargv)         | 获取编译命令行列表                           | >= 2.1.5 |
| [compiler.compflags](#compiler-compflags)       | 获取编译选项                                 | >= 2.0.1 |
| [compiler.has_flags](#compiler-has_flags)       | 判断指定编译选项是否支持                     | >= 2.1.5 |
| [compiler.features](#compiler-features)         | 获取所有编译器特性                           | >= 2.1.5 |
| [compiler.has_features](#compiler-has_features) | 判断指定编译特性是否支持                     | >= 2.1.5 |

###### compiler.compile

- 执行编译

针对target，链接指定对象文件列表，生成对应的目标文件，例如：

```lua
compiler.compile("xxx.c", "xxx.o", "xxx.h.d", {target = target})
```

其中[target](#target)，为工程目标，这里传入主要用于获取taeget的特定编译选项，具体如果获取工程目标对象，见：[core.project.project](#core-project-project)

而`xxx.h.d`文件用于存储为此源文件的头文件依赖文件列表，最后这两个参数都是可选的，编译的时候可以不传他们：

```lua
compiler.compile("xxx.c", "xxx.o")
```

来单纯编译一个源文件。

###### compiler.compcmd

- 获取编译命令行

直接获取[compiler.compile](#compiler-compile)中执行的命令行字符串，相当于：

```lua
local cmdstr = compiler.compcmd("xxx.c", "xxx.o", {target = target})
```

注：后面`{target = target}`扩展参数部分是可选的，如果传递了target对象，那么生成的编译命令，会加上这个target配置对应的链接选项。

并且还可以自己传递各种配置，例如：

```lua
local cmdstr = compiler.compcmd("xxx.c", "xxx.o", {config = {includedirs = "/usr/include", defines = "DEBUG"}})
```

通过target，我们可以导出指定目标的所有源文件编译命令：

```lua
import("core.project.project")

for _, target in pairs(project.targets()) do
    for sourcekind, sourcebatch in pairs(target:sourcebatches()) do
        for index, objectfile in ipairs(sourcebatch.objectfiles) do
            local cmdstr = compiler.compcmd(sourcebatch.sourcefiles[index], objectfile, {target = target})
        end
    end
end
```

###### compiler.compargv

- 获取编译命令行列表

跟[compiler.compargv](#compiler-compargv)稍微有点区别的是，此接口返回的是参数列表，table表示，更加方便操作：

```lua
local program, argv = compiler.compargv("xxx.c", "xxx.o")
```

###### compiler.compflags

- 获取编译选项

获取[compiler.compcmd](#compiler-compcmd)中的编译选项字符串部分，不带shellname和文件列表，例如：

```lua
local flags = compiler.compflags(sourcefile, {target = target})
for _, flag in ipairs(flags) do
    print(flag)
end
```

返回的是flags的列表数组。

###### compiler.has_flags

- 判断指定编译选项是否支持

虽然通过[lib.detect.has_flags](detect-has_flags)也能判断，但是那个接口更加底层，需要指定编译器名称。
而此接口只需要指定语言类型，它会自动切换选择当前支持的编译器。

```lua
-- 判断c语言编译器是否支持选项: -g
if compiler.has_flags("c", "-g") then
    -- ok
end

-- 判断c++语言编译器是否支持选项: -g
if compiler.has_flags("cxx", "-g") then
    -- ok
end
```

###### compiler.features

- 获取所有编译器特性

虽然通过[lib.detect.features](detect-features)也能获取，但是那个接口更加底层，需要指定编译器名称。
而此接口只需要指定语言类型，它会自动切换选择当前支持的编译器，然后获取当前的编译器特性列表。

```lua
-- 获取当前c语言编译器的所有特性
local features = compiler.features("c")

-- 获取当前c++语言编译器的所有特性，启用c++11标准，否则获取不到新标准的特性
local features = compiler.features("cxx", {config = {cxxflags = "-std=c++11"}})

-- 获取当前c++语言编译器的所有特性，传递工程target的所有配置信息
local features = compiler.features("cxx", {target = target, config = {defines = "..", includedirs = ".."}})
```

所有c编译器特性列表：

| 特性名                |
| --------------------- |
| c_static_assert       |
| c_restrict            |
| c_variadic_macros     |
| c_function_prototypes |

所有c++编译器特性列表：

| 特性名                               |
| ------------------------------------ |
| cxx_variable_templates               |
| cxx_relaxed_constexpr                |
| cxx_aggregate_default_initializers   |
| cxx_contextual_conversions           |
| cxx_attribute_deprecated             |
| cxx_decltype_auto                    |
| cxx_digit_separators                 |
| cxx_generic_lambdas                  |
| cxx_lambda_init_captures             |
| cxx_binary_literals                  |
| cxx_return_type_deduction            |
| cxx_decltype_incomplete_return_types |
| cxx_reference_qualified_functions    |
| cxx_alignof                          |
| cxx_attributes                       |
| cxx_inheriting_constructors          |
| cxx_thread_local                     |
| cxx_alias_templates                  |
| cxx_delegating_constructors          |
| cxx_extended_friend_declarations     |
| cxx_final                            |
| cxx_nonstatic_member_init            |
| cxx_override                         |
| cxx_user_literals                    |
| cxx_constexpr                        |
| cxx_defaulted_move_initializers      |
| cxx_enum_forward_declarations        |
| cxx_noexcept                         |
| cxx_nullptr                          |
| cxx_range_for                        |
| cxx_unrestricted_unions              |
| cxx_explicit_conversions             |
| cxx_lambdas                          |
| cxx_local_type_template_args         |
| cxx_raw_string_literals              |
| cxx_auto_type                        |
| cxx_defaulted_functions              |
| cxx_deleted_functions                |
| cxx_generalized_initializers         |
| cxx_inline_namespaces                |
| cxx_sizeof_member                    |
| cxx_strong_enums                     |
| cxx_trailing_return_types            |
| cxx_unicode_literals                 |
| cxx_uniform_initialization           |
| cxx_variadic_templates               |
| cxx_decltype                         |
| cxx_default_function_template_args   |
| cxx_long_long_type                   |
| cxx_right_angle_brackets             |
| cxx_rvalue_references                |
| cxx_static_assert                    |
| cxx_extern_templates                 |
| cxx_func_identifier                  |
| cxx_variadic_macros                  |
| cxx_template_template_parameters     |

###### compiler.has_features

- 判断指定的编译器特性是否支持

虽然通过[lib.detect.has_features](detect-has-features)也能获取，但是那个接口更加底层，需要指定编译器名称。
而此接口只需要指定需要检测的特姓名称列表，就能自动切换选择当前支持的编译器，然后判断指定特性在当前的编译器中是否支持。

```lua
if compiler.has_features("c_static_assert") then
    -- ok
end

if compiler.has_features({"c_static_assert", "cxx_constexpr"}, {languages = "cxx11"}) then
    -- ok
end

if compiler.has_features("cxx_constexpr", {target = target, defines = "..", includedirs = ".."}) then
    -- ok
end
```

具体特性名有哪些，可以参考：[compiler.features](#compiler-features)。

##### core.project.config

用于获取工程编译时候的配置信息，也就是`xmake f|config --xxx=val` 传入的参数选项值。

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [config.get](#config-get)                       | 获取指定配置值                               | >= 2.0.1 |
| [config.load](#config-load)                     | 加载配置                                     | >= 2.0.1 |
| [config.arch](#config-arch)                     | 获取当前工程的架构配置                       | >= 2.0.1 |
| [config.plat](#config-plat)                     | 获取当前工程的平台配置                       | >= 2.0.1 |
| [config.mode](#config-mode)                     | 获取当前工程的编译模式配置                   | >= 2.0.1 |
| [config.buildir](#config-buildir)               | 获取当前工程的输出目录配置                   | >= 2.0.1 |
| [config.directory](#config-directory)           | 获取当前工程的配置信息目录                   | >= 2.0.1 |
| [config.dump](#config-dump)                     | 打印输出当前工程的所有配置信息               | >= 2.0.1 |

###### config.get

- 获取指定配置值

用于获取`xmake f|config --xxx=val`的配置值，例如：

```lua
target("test")
    on_run(function (target)

        -- 导入配置模块
        import("core.project.config")

        -- 获取配置值
        print(config.get("xxx"))
    end)
```

###### config.load

- 加载配置

一般用于插件开发中，插件任务中不像工程的自定义脚本，环境需要自己初始化加载，默认工程配置是没有被加载的，如果要用[config.get](#config-get)接口获取工程配置，那么需要先：

```lua

-- 导入配置模块
import("core.project.config")

function main(...)

    -- 先加载工程配置
    config.load()
    
    -- 获取配置值
    print(config.get("xxx"))
end
```

###### config.arch

- 获取当前工程的架构配置

也就是获取`xmake f|config --arch=armv7`的平台配置，相当于`config.get("arch")`。

###### config.plat

- 获取当前工程的平台配置

也就是获取`xmake f|config --plat=iphoneos`的平台配置，相当于`config.get("plat")`。

###### config.mode

- 获取当前工程的编译模式配置

也就是获取`xmake f|config --mode=debug`的平台配置，相当于`config.get("mode")`。

###### config.buildir

- 获取当前工程的输出目录配置

也就是获取`xmake f|config -o /tmp/output`的平台配置，相当于`config.get("buildir")`。

###### config.directory

- 获取当前工程的配置信息目录

获取工程配置的存储目录，默认为：`projectdir/.config`

###### config.dump

- 打印输出当前工程的所有配置信息

输出结果例如：

```lua
{
    sh = "xcrun -sdk macosx clang++"
,   xcode_dir = "/Applications/Xcode.app"
,   ar = "xcrun -sdk macosx ar"
,   small = true
,   object = false
,   arch = "x86_64"
,   xcode_sdkver = "10.12"
,   ex = "xcrun -sdk macosx ar"
,   cc = "xcrun -sdk macosx clang"
,   rc = "rustc"
,   plat = "macosx"
,   micro = false
,   host = "macosx"
,   as = "xcrun -sdk macosx clang"
,   dc = "dmd"
,   gc = "go"
,   openssl = false
,   ccache = "ccache"
,   cxx = "xcrun -sdk macosx clang"
,   sc = "xcrun -sdk macosx swiftc"
,   mm = "xcrun -sdk macosx clang"
,   buildir = "build"
,   mxx = "xcrun -sdk macosx clang++"
,   ld = "xcrun -sdk macosx clang++"
,   mode = "release"
,   kind = "static"
}
```

##### core.project.global

<p class="tip">
此模块自2.1.5版本后迁移至[core.base.global](#core-base-global)。
</p>

##### core.project.task

<p class="tip">
此模块自2.1.5版本后迁移至[core.base.task](#core-base-task)。
</p>

##### core.project.project

用于获取当前工程的一些描述信息，也就是在`xmake.lua`工程描述文件中定义的配置信息，例如：[target](#target)、[option](#option)等。

| 接口                                            | 描述                                         | 支持版本             |
| ----------------------------------------------- | -------------------------------------------- | -------------------- |
| [project.load](#project-load)                   | 加载工程配置                                 | >= 2.0.1 (2.1.5废弃) |
| [project.directory](#project-directory)         | 获取工程目录                                 | >= 2.0.1             |
| [project.target](#project-target)               | 获取指定工程目标对象                         | >= 2.0.1             |
| [project.targets](#project-targets)             | 获取工程目标对象列表                         | >= 2.0.1             |
| [project.option](#project-option)               | 获取指定的选项对象                           | >= 2.1.5             |
| [project.options](#project-options)             | 获取工程所有的选项对象                       | >= 2.1.5             |
| [project.name](#project-name)                   | 获取当前工程名                               | >= 2.0.1             |
| [project.version](#project-version)             | 获取当前工程版本号                           | >= 2.0.1             |

###### project.load

- 加载工程描述配置

仅在插件中使用，因为这个时候还没有加载工程配置信息，在工程目标的自定义脚本中，不需要执行此操作，就可以直接访问工程配置。

```lua
-- 导入工程模块
import("core.project.project")

-- 插件入口
function main(...)

    -- 加载工程描述配置
    project.load()

    -- 访问工程描述，例如获取指定工程目标
    local target = project.target("test")
end
```

<p class="tip">
2.1.5版本后，不在需要，工程加载会自动在合适时机延迟加载。
</p>

###### project.directory

- 获取工程目录

获取当前工程目录，也就是`xmake -P xxx`中指定的目录，否则为默认当前`xmake`命令执行目录。

<p class="tip">
2.1.5版本后，建议使用[os.projectdir](#os-projectdir)来获取。
</p>

###### project.target

- 获取指定工程目标对象

获取和访问指定工程目标配置，例如：

```lua
local target = project.target("test")
if target then

    -- 获取目标名
    print(target:name())

    -- 获取目标目录, 2.1.9版本之后才有
    print(target:targetdir())

    -- 获取目标文件名
    print(target:targetfile())

    -- 获取目标类型，也就是：binary, static, shared
    print(target:targetkind())

    -- 获取目标名
    print(target:name())

    -- 获取目标源文件
    local sourcefiles = target:sourcefiles()

    -- 获取目标安装头文件列表
    local srcheaders, dstheaders = target:headerfiles()

    -- 获取目标依赖
    print(target:get("deps"))
end
```

###### project.targets

- 获取工程目标对象列表

返回当前工程的所有编译目标，例如：

```lua
for targetname, target in pairs(project.targets())
    print(target:targetfile())
end
```

###### project.option

- 获取指定选项对象

获取和访问工程中指定的选项对象，例如：

```lua
local option = project.option("test")
if option:enabled() then
    option:enable(false)
end
```

###### project.options

- 获取工程所有选项对象

返回当前工程的所有编译目标，例如：

```lua
for optionname, option in pairs(project.options())
    print(option:enabled())
end
```

###### project.name

- 获取当前工程名

也就是获取[set_project](#set_project)的工程名配置。

```lua
print(project.name())
```

###### project.version

- 获取当前工程版本号

也就是获取[set_version](#set_version)的工程版本配置。

```lua
print(project.version())
```

##### core.language.language

用于获取编译语言相关信息，一般用于代码文件的操作。

| 接口                                              | 描述                                         | 支持版本 |
| -----------------------------------------------   | -------------------------------------------- | -------- |
| [language.extensions](#language-extensions)       | 获取所有语言的代码后缀名列表                 | >= 2.1.1 |
| [language.targetkinds](#language-targetkinds)     | 获取所有语言的目标类型列表                   | >= 2.1.1 |
| [language.sourcekinds](#language-sourcekinds)     | 获取所有语言的源文件类型列表                 | >= 2.1.1 |
| [language.sourceflags](#language-sourceflags)     | 加载所有语言的源文件编译选项名列表           | >= 2.1.1 |
| [language.load](#language-load)                   | 加载指定语言                                 | >= 2.1.1 |
| [language.load_sk](#language-load_sk)             | 从源文件类型加载指定语言                     | >= 2.1.1 |
| [language.load_ex](#language-load_ex)             | 从源文件后缀名加载指定语言                   | >= 2.1.1 |
| [language.sourcekind_of](#language-sourcekind_of) | 获取指定源文件的源文件类型                   | >= 2.1.1 |

###### language.extensions

- 获取所有语言的代码后缀名列表

获取结果如下：

```lua
{
     [".c"]      = cc
,    [".cc"]     = cxx
,    [".cpp"]    = cxx
,    [".m"]      = mm
,    [".mm"]     = mxx
,    [".swift"]  = sc
,    [".go"]     = gc
}
```

###### language.targetkinds

- 获取所有语言的目标类型列表

获取结果如下：

```lua
{
     binary = {"ld", "gc-ld", "dc-ld"}
,    static = {"ar", "gc-ar", "dc-ar"}
,    shared = {"sh", "dc-sh"}
}
```

###### language.sourcekinds

- 获取所有语言的源文件类型列表

获取结果如下：

```lua
{
     cc  = ".c"
,    cxx = {".cc", ".cpp", ".cxx"}
,    mm  = ".m"
,    mxx = ".mm"
,    sc  = ".swift"
,    gc  = ".go"
,    rc  = ".rs"
,    dc  = ".d"
,    as  = {".s", ".S", ".asm"}
}
```

###### language.sourceflags

- 加载所有语言的源文件编译选项名列表

获取结果如下：

```lua
{
     cc  = {"cflags", "cxflags"}
,    cxx = {"cxxflags", "cxflags"}
,    ...
}
```

###### language.load

- 加载指定语言

从语言名称加载具体语言对象，例如：

```lua
local lang = language.load("c++")
if lang then
    print(lang:name())
end
```

###### language.load_sk

- 从源文件类型加载指定语言

从源文件类型：`cc, cxx, mm, mxx, sc, gc, as ..`加载具体语言对象，例如：

```lua
local lang = language.load_sk("cxx")
if lang then
    print(lang:name())
end
```

###### language.load_ex

- 从源文件后缀名加载指定语言

从源文件后缀名：`.cc, .c, .cpp, .mm, .swift, .go  ..`加载具体语言对象，例如：

```lua
local lang = language.load_sk(".cpp")
if lang then
    print(lang:name())
end
```

###### language.sourcekind_of

- 获取指定源文件的源文件类型

也就是从给定的一个源文件路径，获取它是属于那种源文件类型，例如：

```lua
print(language.sourcekind_of("/xxxx/test.cpp"))
```

显示结果为：`cxx`，也就是`c++`类型，具体对应列表见：[language.sourcekinds](#language-sourcekinds)

##### core.platform.platform

平台信息相关操作

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [platform.get](#platform-get)                   | 获取指定平台相关配置信息                     | >= 2.0.1 |

###### platform.get

- 获取指定平台相关配置信息

获取平台配置`xmake.lua`中设置的信息，一般只有在写插件的时候会用到，例如：

```lua
-- 获取当前平台的所有支持架构
print(platform.get("archs"))

-- 获取指定iphoneos平台的目标文件格式信息
local formats = platform.get("formats", "iphoneos")
table.dump(formats)
```

具体有哪些可读的平台配置信息，可参考：[platform](#platform)

##### core.platform.environment

环境相关操作，用于进入和离开指定环境变量对应的终端环境，一般用于`path`环境的进入和离开，尤其是一些需要特定环境的构建工具，例如：msvc的工具链。

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| [environment.enter](#environment-enter)         | 进入指定环境                                 | >= 2.0.1 |
| [environment.leave](#environment-leave)         | 离开指定环境                                 | >= 2.0.1 |

目前支持的环境有：

| 接口                                            | 描述                                         | 支持版本 |
| ----------------------------------------------- | -------------------------------------------- | -------- |
| toolchains                                      | 工具链执行环境                               | >= 2.0.1 |

###### environment.enter

- 进入指定环境

进入指定环境，例如msvc有自己的环境变量环境用于运行构建工具，例如：`cl.exe`, `link.exe`这些，这个时候想要在xmake里面运行他们，需要：

```lua
-- 进入工具链环境
environment.enter("toolchains")

-- 这个时候运行cl.exe才能正常运行，这个时候的path等环境变量都会进入msvc的环境模式
os.run("cl.exe ..")

-- 离开工具链环境
environment.leave("toolchains")
```

因此为了通用性，默认xmake编译事都会设置这个环境，在linux下基本上内部环境不需要特殊切换，目前仅对windows下msvc进行了处理。

###### environment.leave

- 离开指定环境

具体使用见：[environment.enter](#environment-enter)

##### lib.detect

此模块提供了非常强大的探测功能，用于探测程序、编译器、语言特性、依赖包等。

<p class="tip">
此模块的接口分散在多个模块目录中，尽量通过导入单个接口来使用，这样效率更高，例如：`import("lib.detect.find_package")`，而不是通过`import("lib.detect")`导入所有来调用。
</p>

| 接口                                                | 描述                                         | 支持版本             |
| --------------------------------------------------- | -------------------------------------------- | -------------------- |
| [detect.find_file](#detect-find_file)               | 查找文件                                     | >= 2.1.5             |
| [detect.find_path](#detect-find_path)               | 查找文件路径                                 | >= 2.1.5             |
| [detect.find_library](#detect-find_library)         | 查找库文件                                   | >= 2.1.5             |
| [detect.find_program](#detect-find_program)         | 查找可执行程序                               | >= 2.1.5             |
| [detect.find_programver](#detect-find_programver)   | 查找可执行程序版本号                         | >= 2.1.5             |
| [detect.find_package](#detect-find_package)         | 查找包文件，包含库文件和搜索路径             | >= 2.1.5             |
| [detect.find_tool](#detect-find_tool)               | 查找工具                                     | >= 2.1.5             |
| [detect.find_toolname](#detect-find_toolname)       | 查找工具名                                   | >= 2.1.5             |
| [detect.find_cudadevices](#detect-find_cudadevices) | 查找本机的 CUDA 设备                         | >= 2.2.7             |
| [detect.features](#detect-features)                 | 获取指定工具的所有特性                       | >= 2.1.5             |
| [detect.has_features](#detect-has_features)         | 判断指定特性是否支持                         | >= 2.1.5             |
| [detect.has_flags](#detect-has_flags)               | 判断指定参数选项是否支持                     | >= 2.1.5             |
| [detect.has_cfuncs](#detect-has_cfuncs)             | 判断指定c函数是否存在                        | >= 2.1.5             |
| [detect.has_cxxfuncs](#detect-has_cxxfuncs)         | 判断指定c++函数是否存在                      | >= 2.1.5             |
| [detect.has_cincludes](#detect-has_cincludes)       | 判断指定c头文件是否存在                      | >= 2.1.5             |
| [detect.has_cxxincludess](#detect-has_cxxincludes)  | 判断指定c++头文件是否存在                    | >= 2.1.5             |
| [detect.has_ctypes](#detect-has_ctypes)             | 判断指定c类型是否存在                        | >= 2.1.5             |
| [detect.has_cxxtypes](#detect-has_cxxtypes)         | 判断指定c++类型是否存在                      | >= 2.1.5             |
| [detect.check_cxsnippets](#detect-check_cxsnippets) | 检测c/c++代码片段是否能够编译通过            | >= 2.1.5             |

###### detect.find_file

- 查找文件

这个接口提供了比[os.files](#os-files)更加强大的工程， 可以同时指定多个搜索目录，并且还能对每个目录指定附加的子目录，来模式匹配查找，相当于是[os.files](#os-files)的增强版。

例如：

```lua
import("lib.detect.find_file")

local file = find_file("ccache", { "/usr/bin", "/usr/local/bin"})
```

如果找到，返回的结果是：`/usr/bin/ccache`

它同时也支持模式匹配路径，进行递归查找，类似`os.files`：

```lua
local file = find_file("test.h", { "/usr/include", "/usr/local/include/**"})
```

不仅如此，里面的路径也支持内建变量，来从环境变量和注册表中获取路径进行查找：

```lua
local file = find_file("xxx.h", { "$(env PATH)", "$(reg HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\XXXX;Name)"})
```

如果路径规则比较复杂多变，还可以通过自定义脚本来动态生成路径传入：

```lua
local file = find_file("xxx.h", { "$(env PATH)", function () return val("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\XXXX;Name"):match("\"(.-)\"") end})
```

大部分场合下，上面的使用已经满足各种需求了，如果还需要一些扩展功能，可以通过传入第三个参数，自定义一些可选配置，例如：

```lua
local file = find_file("test.h", { "/usr", "/usr/local"}, {suffixes = {"/include", "/lib"}})
```

通过指定suffixes子目录列表，可以扩展路径列表（第二个参数），使得实际的搜索目录扩展为：

```
/usr/include
/usr/lib
/usr/local/include
/usr/local/lib
```

并且不用改变路径列表，就能动态切换子目录来搜索文件。

<p class="tip">
我们也可以通过`xmake lua`插件来快速调用和测试此接口：`xmake lua lib.detect.find_file test.h /usr/local`
</p>

###### detect.find_path

- 查找路径

这个接口的用法跟[lib.detect.find_file](#detect-find_file)类似，唯一的区别是返回的结果不同。
此接口查找到传入的文件路径后，返回的是对应的搜索路径，而不是文件路径本身，一般用于查找文件对应的父目录位置。

```lua
import("lib.detect.find_path")

local p = find_path("include/test.h", { "/usr", "/usr/local"})
```

上述代码如果查找成功，则返回：`/usr/local`，如果`test.h`在`/usr/local/include/test.h`的话。

还有一个区别就是，这个接口传入不只是文件路径，还可以传入目录路径来查找：

```lua
local p = find_path("lib/xxx", { "$(env PATH)", "$(reg HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\XXXX;Name)"})
```

同样，此接口也支持模式匹配和后缀子目录：

```lua
local p = find_path("include/*.h", { "/usr", "/usr/local/**"}, {suffixes = "/subdir"})
```

###### detect.find_library

- 查找库文件

此接口用于指定的搜索目录中查找库文件（静态库，动态库），例如：

```lua
import("lib.detect.find_library")

local library = find_library("crypto", {"/usr/lib", "/usr/local/lib"})
```

在macosx上运行，返回的结果如下：

```lua
{
    filename = libcrypto.dylib
,   linkdir = /usr/lib
,   link = crypto
,   kind = shared
}
```

如果不指定是否需要静态库还是动态库，那么此接口会自动选择一个存在的库（有可能是静态库、也有可能是动态库）进行返回。

如果需要强制指定需要查找的库类型，可以指定kind参数为（`static/shared`）：

```lua
local library = find_library("crypto", {"/usr/lib", "/usr/local/lib"}, {kind = "static"})
```

此接口也支持suffixes后缀子目录搜索和模式匹配操作：

```lua
local library = find_library("cryp*", {"/usr", "/usr/local"}, {suffixes = "/lib"})
```

###### detect.find_program

- 查找可执行程序

这个接口比[lib.detect.find_tool](#detect-find_tool)较为原始底层，通过指定的参数目录来查找可执行程序。

```lua
import("lib.detect.find_program")

local program = find_program("ccache")
```

上述代码犹如没有传递搜索目录，所以它会尝试直接执行指定程序，如果运行ok，那么直接返回：`ccache`，表示查找成功。

指定搜索目录，修改尝试运行的检测命令参数（默认是：`ccache --version`）：

```lua
local program = find_program("ccache", {pathes = {"/usr/bin", "/usr/local/bin"}, check = "--help"}) 
```

上述代码会尝试运行：`/usr/bin/ccache --help`，如果运行成功，则返回：`/usr/bin/ccache`。

如果`--help`也没法满足需求，有些程序没有`--version/--help`参数，那么可以自定义运行脚本，来运行检测：

```lua
local program = find_program("ccache", {pathes = {"/usr/bin", "/usr/local/bin"}, check = function (program) os.run("%s -h", program) end})
```

同样，搜索路径列表支持内建变量和自定义脚本：

```lua
local program = find_program("ccache", {pathes = {"$(env PATH)", "$(reg HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\AeDebug;Debugger)"}})
local program = find_program("ccache", {pathes = {"$(env PATH)", function () return "/usr/local/bin" end}})
```

<p class="tip">
为了加速频发查找的效率，此接口是默认自带cache的，所以就算频繁查找相同的程序，也不会花太多时间。
如果要禁用cache，可以在工程目录执行`xmake f -c`清除本地cache。
</p>

我们也可以通过`xmake lua lib.detect.find_program ccache` 来快速测试。

###### detect.find_programver

- 查找可执行程序版本号


```lua
import("lib.detect.find_programver")

local programver = find_programver("ccache")
```

返回结果为：3.2.2

默认它会通过`ccache --version`尝试获取版本，如果不存在此参数，可以自己指定其他参数：

```lua
local version = find_programver("ccache", {command = "-v"})
```

甚至自定义版本获取脚本：

```lua
local version = find_programver("ccache", {command = function () return os.iorun("ccache --version") end})
```

对于版本号的提取规则，如果内置的匹配模式不满足要求，也可以自定义：

```lua
local version = find_programver("ccache", {command = "--version", parse = "(%d+%.?%d*%.?%d*.-)%s"})
local version = find_programver("ccache", {command = "--version", parse = function (output) return output:match("(%d+%.?%d*%.?%d*.-)%s") end})
```

<p class="tip">
为了加速频发查找的效率，此接口是默认自带cache的，如果要禁用cache，可以在工程目录执行`xmake f -c`清除本地cache。
</p>

我们也可以通过`xmake lua lib.detect.find_programver ccache` 来快速测试。

###### detect.find_package

- 查找包文件

此接口也是用于查找库文件，但是比[lib.detect.find_library](#detect-find_library)更加上层，也更为强大和简单易用，因为它是以包为力度进行查找。

那怎样算是一个完整的包，它包含：

1. 多个静态库或者动态库文件
2. 库的搜索目录
3. 头文件的搜索目录
4. 可选的编译链接选项，例如：`defines`等
5. 可选的版本号

例如我们查找一个openssl包：

```lua
import("lib.detect.find_package")

local package = find_package("openssl")
```

返回的结果如下：

```lua
{links = {"ssl", "crypto", "z"}, linkdirs = {"/usr/local/lib"}, includedirs = {"/usr/local/include"}}
```

如果查找成功，则返回一个包含所有包信息的table，如果失败返回nil

这里的返回结果可以直接作为`target:add`, `option:add`的参数传入，用于动态增加`target/option`的配置：

```lua
option("zlib")
    set_showmenu(true)
    before_check(function (option)
        import("lib.detect.find_package")
        option:add(find_package("zlib"))
    end)
```

```lua
target("test")
    on_load(function (target)
        import("lib.detect.find_package")
        target:add(find_package("zlib"))
    end)
```

如果系统上装有`homebrew`, `pkg-config`等第三方工具，那么此接口会尝试使用它们去改进查找结果。

我们也可以通过指定版本号，来选择查找指定版本的包（如果这个包获取不到版本信息或者没有匹配版本的包，则返回nil）：

```lua
local package = find_package("openssl", {version = "1.0.1"})
```

默认情况下查找的包是根据如下规则匹配平台，架构和模式的：

1. 如果参数传入指定了`{plat = "iphoneos", arch = "arm64", mode = "release"}`，则优先匹配，例如：`find_package("openssl", {plat = "iphoneos"})`。
2. 如果是在当前工程环境，存在配置文件，则优先尝试从`config.get("plat")`, `config.get("arch")`和`config.get("mode")`获取平台架构进行匹配。
3. 最后从`os.host()`和`os.arch()`中进行匹配，也就是当前主机的平台架构环境。

如果系统的库目录以及`pkg-config`都不能满足需求，找不到包，那么可以自己手动设置搜索路径：

```lua
local package = find_package("openssl", {linkdirs = {"/usr/lib", "/usr/local/lib"}, includedirs = "/usr/local/include"})
```

也可以同时指定需要搜索的链接名，头文件名：

```lua
local package = find_package("openssl", {links = {"ssl", "crypto"}, includes = "ssl.h"}})
```

甚至可以指定xmake的`packagedir/*.pkg`包目录，用于查找对应的`openssl.pkg`包，一般用于查找内置在工程目录中的本地包。

例如，tbox工程内置了`pkg/openssl.pkg`本地包载项目中，我们可以通过下面的脚本，传入`{packagedirs = ""}`参数优先查找本地包，如果找不到再去找系统包。

```lua
target("test")
    on_load(function (target)
        import("lib.detect.find_package")
        target:add(find_package("openssl", {packagedirs = path.join(os.projectdir(), "pkg")}))
    end)
```

总结下，现在的查找顺序：

1. 如果指定`{packagedirs = ""}`参数，优先从这个参数指定的路径中查找本地包`*.pkg`
2. 如果在`xmake/modules`下面存在`detect.packages.find_xxx`脚本，那么尝试调用此脚本来改进查找结果
3. 如果系统存在vcpkg，优先从vcpkg的包管理系统中去获取包
4. 如果系统存在`pkg-config`，并且查找的是系统环境的库，则尝试使用`pkg-config`提供的路径和链接信息进行查找
5. 如果系统存在`homebrew`，并且查找的是系统环境的库，则尝试使用`brew --prefix xxx`提供的信息进行查找
6. 从参数中指定的pathes路径和一些已知的系统路径`/usr/lib`, `/usr/include`中进行查找

这里需要着重说下第二点，通过在`detect.packages.find_xxx`脚本来改进查找结果，很多时候自动的包探测是没法完全探测到包路径的，
尤其是针对windows平台，没有默认的库目录，也没有包管理app，很多库装的时候，都是自己所处放置在系统目录，或者添加注册表项。

因此查找起来没有统一的规则，这个时候，就可以自定义一个查找脚本，去改进`find_package`的查找机制，对指定包进行更精准的查找。

在xmake自带的`xmake/modules/detect/packages`目录下，已经有许多的内置包脚本，来对常用的包进行更好的查找支持。
当然这不可能满足所有用户的需求，如果用户需要的包还是找不到，那么可以自己定义一个查找脚本，例如：

查找一个名为`openssl`的包，可以编写一个`find_openssl.lua`的脚本放置在工程目录：

```
projectdir
 - xmake
   - modules
     - detect/package/find_openssl.lua
```

然后在工程的`xmake.lua`文件的开头指定下这个modules的目录：

```lua
add_moduledirs("$(projectdir)/xmake/modules")
```

这样xmake就能找到自定义的扩展模块了。

接下来我们看下`find_openssl.lua`的实现：

```lua
-- imports
import("lib.detect.find_path")
import("lib.detect.find_library")

-- find openssl 
--
-- @param opt   the package options. e.g. see the options of find_package()
--
-- @return      see the return value of find_package()
--
function main(opt)

    -- for windows platform
    --
    -- http://www.slproweb.com/products/Win32OpenSSL.html
    --
    if opt.plat == "windows" then

        -- init bits
        local bits = ifelse(opt.arch == "x64", "64", "32")

        -- init search pathes
        local pathes = {"$(reg HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenSSL %(" .. bits .. "-bit%)_is1;Inno Setup: App Path)",
                        "$(env PROGRAMFILES)/OpenSSL",
                        "$(env PROGRAMFILES)/OpenSSL-Win" .. bits,
                        "C:/OpenSSL",
                        "C:/OpenSSL-Win" .. bits}

        -- find library
        local result = {links = {}, linkdirs = {}, includedirs = {}}
        for _, name in ipairs({"libssl", "libcrypto"}) do
            local linkinfo = find_library(name, pathes, {suffixes = "lib"})
            if linkinfo then
                table.insert(result.links, linkinfo.link)
                table.insert(result.linkdirs, linkinfo.linkdir)
            end
        end

        -- not found?
        if #result.links ~= 2 then
            return 
        end

        -- find include
        table.insert(result.includedirs, find_path("openssl/ssl.h", pathes, {suffixes = "include"}))

        -- ok
        return result
    end
end
```

里面对windows平台进行注册表读取，去查找指定的库文件，其底层其实也是调用的[find_library](#detect-find_library)等接口。

<p class="tip">
为了加速频发查找的效率，此接口是默认自带cache的，如果要禁用cache，可以在工程目录执行`xmake f -c`清除本地cache。
也可以通过指定force参数，来禁用cache，强制重新查找：`find_package("openssl", {force = true})`
</p>

我们也可以通过`xmake lua lib.detect.find_package openssl` 来快速测试。

2.2.5版本之后，新增了内置接口[find_packages](#find_packages)，可以同时查找多个包，并且不需要通过import导入即可直接使用。

并且此版本之后，支持显式的从指定第三方包管理器中查找包，例如：

```lua
find_package("brew::pcre2/libpcre2-8")
```

由于每个第三方包管理器的包名不完全一致，比如pcre2在homebrew中有三个库版本，我们可以通过上面的方式，指定查找对应libpcre2-8版本的库。

另外，对于vcpkg, conan也可以通过加上`vcpkg::`, `conan::`包命名空间来指定查找里面的库。

###### detect.find_tool

- 查找工具

此接口也是用于查找可执行程序，不过比[lib.detect.find_program](#detect-find_program)更加的高级，功能也更加强大，它对可执行程序进行了封装，提供了工具这个概念：

* toolname: 工具名，可执行程序的简称，用于标示某个工具，例如：`gcc`, `clang`等
* program: 可执行程序命令，例如：`xcrun -sdk macosx clang`

其对应关系如下：

| toolname  | program                             |
| --------- | ----------------------------------- |
| clang     | `xcrun -sdk macosx clang`           |
| gcc       | `/usr/toolchains/bin/arm-linux-gcc` |
| link      | `link.exe -lib`                     |

[lib.detect.find_program](#detect-find_program)只能通过传入的原始program命令或路径，去判断该程序是否存在。
而`find_tool`则可以通过更加一致的toolname去查找工具，并且返回对应的program完整命令路径，例如：

```lua
import("lib.detect.find_tool")

local tool = find_tool("clang")
```

返回的结果为：`{name = "clang", program = "clang"}`，这个时候还看不出区别，我们可以手动指定可执行的命令：

```lua
local tool = find_tool("clang", {program = "xcrun -sdk macosx clang"})
```

返回的结果为：`{name = "clang", program = "xcrun -sdk macosx clang"}`

而在macosx下，gcc就是clang，如果我们执行`gcc --version`可以看到就是clang的一个马甲，我们可以通过`find_tool`接口进行智能识别：

```lua
local tool = find_tool("gcc")
```

返回的结果为：`{name = "clang", program = "gcc"}`

通过这个结果就可以看的区别来了，工具名实际会被标示为clang，但是可执行的命令用的是gcc。

我们也可以指定`{version = true}`参数去获取工具的版本，并且指定一个自定义的搜索路径，也支持内建变量和自定义脚本哦： 

```lua
local tool = find_tool("clang", {version = true, {pathes = {"/usr/bin", "/usr/local/bin", "$(env PATH)", function () return "/usr/xxx/bin" end}})
```

返回的结果为：`{name = "clang", program = "/usr/bin/clang", version = "4.0"}`

这个接口是对`find_program`的上层封装，因此也支持自定义脚本检测：

```lua
local tool = find_tool("clang", {check = "--help"}) 
local tool = find_tool("clang", {check = function (tool) os.run("%s -h", tool) end})
```

最后总结下，`find_tool`的查找流程：

1. 优先通过`{program = "xxx"}`的参数来尝试运行和检测。
2. 如果在`xmake/modules/detect/tools`下存在`detect.tools.find_xxx`脚本，则调用此脚本进行更加精准的检测。
3. 尝试从`/usr/bin`，`/usr/local/bin`等系统目录进行检测。

我们也可以在工程`xmake.lua`中`add_moduledirs`指定的模块目录中，添加自定义查找脚本，来改进检测机制：

```
projectdir
  - xmake/modules
    - detect/tools/find_xxx.lua
```

例如我们自定义一个`find_7z.lua`的查找脚本：

```lua
import("lib.detect.find_program")
import("lib.detect.find_programver")

function main(opt)

    -- init options
    opt = opt or {}

    -- find program
    local program = find_program(opt.program or "7z", opt.pathes, opt.check or "--help")

    -- find program version
    local version = nil
    if program and opt and opt.version then
        version = find_programver(program, "--help", "(%d+%.?%d*)%s")
    end

    -- ok?
    return program, version
end
```

将它放置到工程的模块目录下后，执行：`xmake l lib.detect.find_tool 7z`就可以查找到了。

<p class="tip">
为了加速频发查找的效率，此接口是默认自带cache的，如果要禁用cache，可以在工程目录执行`xmake f -c`清除本地cache。
</p>

我们也可以通过`xmake lua lib.detect.find_tool clang` 来快速测试。

###### detect.find_toolname

- 查找工具名

通过program命令匹配对应的工具名，例如：

| program                   | toolname   |
| ------------------------- | ---------- |
| `xcrun -sdk macosx clang` | clang      |
| `/usr/bin/arm-linux-gcc`  | gcc        |
| `link.exe -lib`           | link       |
| `gcc-5`                   | gcc        |
| `arm-android-clang++`     | clangxx    |
| `pkg-config`              | pkg_config |

toolname相比program，更能唯一标示某个工具，也方便查找和加载对应的脚本`find_xxx.lua`。

###### detect.find_cudadevices

- 查找本机的 CUDA 设备

通过 CUDA Runtime API 枚举本机的 CUDA 设备，并查询其属性。

```lua
import("lib.detect.find_cudadevices")

local devices = find_cudadevices({ skip_compute_mode_prohibited = true })
local devices = find_cudadevices({ min_sm_arch = 35, order_by_flops = true })
```

返回的结果为：`{ { ['$id'] = 0, name = "GeForce GTX 960M", major = 5, minor = 0, ... }, ... }`

包含的属性依据当前 CUDA 版本会有所不同，可以参考 [CUDA 官方文档](https://docs.nvidia.com/cuda/cuda-runtime-api/structcudaDeviceProp.html#structcudaDeviceProp)及其历史版本。

###### detect.features

- 获取指定工具的所有特性

此接口跟[compiler.features](#compiler-features)类似，区别就是此接口更加的原始，传入的参数是实际的工具名toolname。

并且此接口不仅能够获取编译器的特性，任何工具的特性都可以获取，因此更加通用。

```lua
import("lib.detect.features")

local features = features("clang")
local features = features("clang", {flags = "-O0", program = "xcrun -sdk macosx clang"})
local features = features("clang", {flags = {"-g", "-O0", "-std=c++11"}})
```

通过传入flags，可以改变特性的获取结果，例如一些c++11的特性，默认情况下获取不到，通过启用`-std=c++11`后，就可以获取到了。

所有编译器的特性列表，可以见：[compiler.features](#compiler-features)。

###### detect.has_features

- 判断指定特性是否支持

此接口跟[compiler.has_features](#compiler-has_features)类似，但是更加原始，传入的参数是实际的工具名toolname。

并且此接口不仅能够判断编译器的特性，任何工具的特性都可以判断，因此更加通用。

```lua
import("lib.detect.has_features")

local features = has_features("clang", "cxx_constexpr")
local features = has_features("clang", {"cxx_constexpr", "c_static_assert"}, {flags = {"-g", "-O0"}, program = "xcrun -sdk macosx clang"})
local features = has_features("clang", {"cxx_constexpr", "c_static_assert"}, {flags = "-g"})
```

如果指定的特性列表存在，则返回实际支持的特性子列表，如果都不支持，则返回nil，我们也可以通过指定flags去改变特性的获取规则。

所有编译器的特性列表，可以见：[compiler.features](#compiler-features)。

###### detect.has_flags

- 判断指定参数选项是否支持

此接口跟[compiler.has_flags](#compiler-has_flags)类似，但是更加原始，传入的参数是实际的工具名toolname。

```lua
import("lib.detect.has_flags")

local ok = has_flags("clang", "-g")
local ok = has_flags("clang", {"-g", "-O0"}, {program = "xcrun -sdk macosx clang"})
local ok = has_flags("clang", "-g -O0", {toolkind = "cxx"})
```

如果检测通过，则返回true。

此接口的检测做了一些优化，除了cache机制外，大部分场合下，会去拉取工具的选项列表（`--help`）直接判断，如果选项列表里获取不到的话，才会通过尝试运行的方式来检测。

###### detect.has_cfuncs

- 判断指定c函数是否存在

此接口是[lib.detect.check_cxsnippets](#detect-check_cxsnippets)的简化版本，仅用于检测函数。

```lua
import("lib.detect.has_cfuncs")

local ok = has_cfuncs("setjmp")
local ok = has_cfuncs({"sigsetjmp((void*)0, 0)", "setjmp"}, {includes = "setjmp.h"})
```

对于函数的描述规则如下：

| 函数描述                                        | 说明          |
| ----------------------------------------------- | ------------- |
| `sigsetjmp`                                     | 纯函数名      |
| `sigsetjmp((void*)0, 0)`                        | 函数调用      |
| `sigsetjmp{int a = 0; sigsetjmp((void*)a, a);}` | 函数名 + {}块 |

在最后的可选参数中，除了可以指定`includes`外，还可以指定其他的一些参数用于控制编译检测的选项条件：

```lua
{ verbose = false, target = [target|option], includes = .., config = {linkdirs = .., links = .., defines = ..}}
```

其中verbose用于回显检测信息，target用于在检测前追加target中的配置信息, 而config用于自定义配置跟target相关的编译选项。

###### detect.has_cxxfuncs

- 判断指定c++函数是否存在

此接口跟[lib.detect.has_cfuncs](#detect-has_cfuncs)类似，请直接参考它的使用说明，唯一区别是这个接口用于检测c++函数。

###### detect.has_cincludes

- 判断指定c头文件是否存在

此接口是[lib.detect.check_cxsnippets](#detect-check_cxsnippets)的简化版本，仅用于检测头文件。

```lua
import("lib.detect.has_cincludes")

local ok = has_cincludes("stdio.h")
local ok = has_cincludes({"stdio.h", "stdlib.h"}, {target = target})
local ok = has_cincludes({"stdio.h", "stdlib.h"}, {config = {defines = "_GNU_SOURCE=1", languages = "cxx11"}})
```

###### detect.has_cxxincludes

- 判断指定c++头文件是否存在

此接口跟[lib.detect.has_cincludess](#detect-has_cincludes)类似，请直接参考它的使用说明，唯一区别是这个接口用于检测c++头文件。

###### detect.has_ctypes

- 判断指定c类型是否存在

此接口是[lib.detect.check_cxsnippets](#detect-check_cxsnippets)的简化版本，仅用于检测函数。

```lua
import("lib.detect.has_ctypes")

local ok = has_ctypes("wchar_t")
local ok = has_ctypes({"char", "wchar_t"}, {includes = "stdio.h"})
local ok = has_ctypes("wchar_t", {includes = {"stdio.h", "stdlib.h"}, config = {"defines = "_GNU_SOURCE=1", languages = "cxx11"}})
```

###### detect.has_cxxtypes

- 判断指定c++类型是否存在

此接口跟[lib.detect.has_ctypess](#detect-has_ctypes)类似，请直接参考它的使用说明，唯一区别是这个接口用于检测c++类型。

###### detect.check_cxsnippets

- 检测c/c++代码片段是否能够编译通过

通用的c/c++代码片段检测接口，通过传入多个代码片段列表，它会自动生成一个编译文件，然后常识对它进行编译，如果编译通过返回true。

对于一些复杂的编译器特性，连[compiler.has_features](#compiler-has_features)都无法检测到的时候，可以通过此接口通过尝试编译来检测它。

```lua
import("lib.detect.check_cxsnippets")

local ok = check_cxsnippets("void test() {}")
local ok = check_cxsnippets({"void test(){}", "#define TEST 1"}, {types = "wchar_t", includes = "stdio.h"})
```

此接口是[detect.has_cfuncs](#detect-has_cfuncs), [detect.has_cincludes](#detect-has_cincludes)和[detect.has_ctypes](detect-has_ctypes)等接口的通用版本，也更加底层。

因此我们可以用它来检测：types, functions, includes 还有 links，或者是组合起来一起检测。

第一个参数为代码片段列表，一般用于一些自定义特性的检测，如果为空，则可以仅仅检测可选参数中条件，例如：

```lua
local ok = check_cxsnippets({}, {types = {"wchar_t", "char*"}, includes = "stdio.h", funcs = {"sigsetjmp", "sigsetjmp((void*)0, 0)"}})
```

上面那个调用，会去同时检测types, includes和funcs是否都满足，如果通过返回true。

还有其他一些可选参数：

```lua
{ verbose = false, target = [target|option], sourcekind = "[cc|cxx]"}
```

其中verbose用于回显检测信息，target用于在检测前追加target中的配置信息, sourcekind 用于指定编译器等工具类型，例如传入`cxx`强制作为c++代码来检测。

##### net.http

此模块提供http的各种操作支持，目前提供的接口如下：

| 接口                                                | 描述                                         | 支持版本             |
| --------------------------------------------------- | -------------------------------------------- | -------------------- |
| [http.download](#http-download)                     | 下载http文件                                 | >= 2.1.5             |

###### http.download

- 下载http文件

这个接口比较简单，就是单纯的下载文件。

```lua
import("net.http")

http.download("https://xmake.io", "/tmp/index.html")
```

##### privilege.sudo

此接口用于通过`sudo`来运行命令，并且提供了平台一致性处理，对于一些需要root权限运行的脚本，可以使用此接口。

<p class="warning">
为了保证安全性，除非必须使用的场合，其他情况下尽量不要使用此接口。
</p>

| 接口                                                | 描述                                         | 支持版本             |
| --------------------------------------------------- | -------------------------------------------- | -------------------- |
| [sudo.has](#sudo-has)                               | 判断sudo是否支持                             | >= 2.1.5             |
| [sudo.run](#sudo-run)                               | 安静运行程序                                 | >= 2.1.5             |
| [sudo.runv](#sudo-runv)                             | 安静运行程序，带参数列表                     | >= 2.1.5             |
| [sudo.exec](#sudo-exec)                             | 回显运行程序                                 | >= 2.1.5             |
| [sudo.execv](#sudo-execv)                           | 回显运行程序，带参数列表                     | >= 2.1.5             |
| [sudo.iorun](#sudo-iorun)                           | 运行并获取程序输出内容                       | >= 2.1.5             |
| [sudo.iorunv](#sudo-iorunv)                         | 运行并获取程序输出内容，带参数列表           | >= 2.1.5             |

###### sudo.has

-  判断sudo是否支持

目前仅在`macosx/linux`下支持sudo，windows上的管理员权限运行暂时还不支持，因此建议使用前可以通过此接口判断支持情况后，针对性处理。

```lua
import("privilege.sudo")

if sudo.has() then
    sudo.run("rm /system/file")
end
```

###### sudo.run

- 安静运行原生shell命令

具体用法可参考：[os.run](#os-run)。

```lua
import("privilege.sudo")

sudo.run("rm /system/file")
```

###### sudo.runv

- 安静运行原生shell命令，带参数列表

具体用法可参考：[os.runv](#os-runv)。

###### sudo.exec

- 回显运行原生shell命令

具体用法可参考：[os.exec](#os-exec)。

###### sudo.execv

- 回显运行原生shell命令，带参数列表

具体用法可参考：[os.execv](#os-execv)。

###### sudo.iorun

- 安静运行原生shell命令并获取输出内容

具体用法可参考：[os.iorun](#os-iorun)。

###### sudo.iorunv

- 安静运行原生shell命令并获取输出内容，带参数列表

具体用法可参考：[os.iorunv](#os-iorunv)。

##### devel.git

此接口提供了git各种命令的访问接口，相对于直接调用git命令，此模块提供了更加上层易用的封装接口，并且提供对git的自动检测和跨平台处理。

<p class="tip">
目前windows上，需要手动安装git包后，才能检测到，后续版本会提供自动集成git功能，用户将不用关心如何安装git，就可以直接使用。
</p>

| 接口                                                | 描述                                         | 支持版本             |
| --------------------------------------------------- | -------------------------------------------- | -------------------- |
| [git.clone](#git-clone)                             | clone代码库                                  | >= 2.1.5             |
| [git.pull](#git-pull)                               | 拉取代码库最新提交                           | >= 2.1.5             |
| [git.clean](#git-clean)                             | 清理代码库文件                               | >= 2.1.5             |
| [git.checkout](#git-checkout)                       | 签出指定分支版本                             | >= 2.1.5             |
| [git.refs](#git-refs)                               | 获取所有引用列表                             | >= 2.1.5             |
| [git.tags](#git-tags)                               | 获取所有标记列表                             | >= 2.1.5             |
| [git.branches](#git-branches)                       | 获取所有分支列表                             | >= 2.1.5             |

###### git.clone

- clone代码库

此接口对应`git clone`命令

```lua
import("devel.git")
 
git.clone("git@github.com:tboox/xmake.git")
git.clone("git@github.com:tboox/xmake.git", {depth = 1, branch = "master", outputdir = "/tmp/xmake"})
```

###### git.pull

- 拉取代码库最新提交

此接口对应`git pull`命令

```lua
import("devel.git")
 
git.pull()
git.pull({remote = "origin", tags = true, branch = "master", repodir = "/tmp/xmake"})
```

###### git.clean

- 清理代码库文件

此接口对应`git clean`命令

```lua
import("devel.git")
 
git.clean()
git.clean({repodir = "/tmp/xmake", force = true})
```

###### git.checkout

- 签出指定分支版本

此接口对应`git checkout`命令

```lua
import("devel.git")
 
git.checkout("master", {repodir = "/tmp/xmake"})
git.checkout("v1.0.1", {repodir = "/tmp/xmake"})
```

###### git.refs

- 获取所有引用列表 

此接口对应`git ls-remote --refs`命令

```lua
import("devel.git")
 
local refs = git.refs(url)
```

###### git.tags

- 获取所有标记列表 

此接口对应`git ls-remote --tags`命令

```lua
import("devel.git")
 
local tags = git.tags(url)
```

###### git.branches

- 获取所有分支列表 

此接口对应`git ls-remote --heads`命令

```lua
import("devel.git")
 
local branches = git.branches(url)
```

##### utils.archive

此模块用于压缩和解压缩文件。

| 接口                                                | 描述                                         | 支持版本             |
| --------------------------------------------------- | -------------------------------------------- | -------------------- |
| [archive.extract](#archive-extract)                 | 解压文件                                     | >= 2.1.5             |

###### archive.extract

- 解压文件

支持大部分常用压缩文件的解压，它会自动检测系统提供了哪些解压工具，然后适配到最合适的解压器对指定压缩文件进行解压操作。

```lua
import("utils.archive")

archive.extract("/tmp/a.zip", "/tmp/outputdir")
archive.extract("/tmp/a.7z", "/tmp/outputdir")
archive.extract("/tmp/a.gzip", "/tmp/outputdir")
archive.extract("/tmp/a.tar.bz2", "/tmp/outputdir")
```