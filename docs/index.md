# 浙江大学 {{ year }} 年春夏学期系统贯通一实验

<!-- NOTE!

正在修改文档的系统 TA 你好！目前我将文档中所有的年份都替换成了 macro 的形式。在你撰写新内容时可以使用 `{{ year }}` 来代替类似 `25` 的年份，用 `{{ year_long }}` 来代替类似 `2025` 的年份。

请确保：mkdocs.yaml 中 `extra.year` `extra.year_long` 被正确修改。同时 yaml 没有很方便的变量替换框架，请注意修改 `site_name` `site_url` `repo_url` `site_name` 的值。

-->

本[仓库](https://git.zju.edu.cn/zju-sys/sys1/sys1-sp{{ year }})是浙江大学 {{ year_long }} 年春夏学期计算系统I课程的教学仓库，包含所有实验文档和公开代码。仓库目录结构：

```bash
├── README.md 
├── docs/       # 实验文档
├── repo/       # 工具链目录
├── mkdocs.yml 
└── src/        # 实验代码
```

实验文档已经部署在了 [zju-git pages](http://zju-sys.pages.zjusct.io/sys1/sys1-sp{{ year }}) 上，方便大家阅读。

## 本地渲染文档

文档采用了 [mkdocs-material](https://squidfunk.github.io/mkdocs-material/) 工具构建和部署。如果想在本地渲染：

```bash
pip3 install mkdocs-material mkdocs-heti-plugin mkdocs-macros-plugin
git clone https://git.zju.edu.cn/zju-sys/sys1/sys1-sp{{ year }}.git
cd sys1-sp{{ year }}
mkdocs serve
```

## 致谢

感谢以下各位助教对本套课程实验的辛勤付出：

- Sp26：冯恺睿、柯怀俊、朱晨硕、蔡雨禾、刘烨、易好、陈宏哲、刘佳鸣、刘新杰、王文烁、洪宇童、汪晟翔、王羽立、侯爵
- Sp25：郭家豪、史璐欣、秦嘉俊、张远帆、洪奕迅、潘潇然、洪宇童、王文烁、汤尧
- Sp24：周杨叶、秦嘉俊、赵恒、杨儒宁
- Sp23：徐金焱、陈杰伟、林浩然
- Sp22：陈卓、林浩然
- Sp21：陈卓、李鸿屹
