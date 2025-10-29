# Clash 代理

## [clash-verge-rev](https://github.com/clash-verge-rev/clash-verge-rev)

### 全局扩展脚本

```JavaScript
// Define main function (script entry)

// 规则集通用配置
const ruleProviderCommon = {
    "type": "http",
    "format": "yaml",
    "interval": 86400
};


const ruleProviders = {
    "reject": {
        ...ruleProviderCommon,
        "behavior": "domain",
        "url": "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/reject.txt",
        "path": "./ruleset/loyalsoldier/reject.yaml"
    },
    "icloud": {
        ...ruleProviderCommon,
        "behavior": "domain",
        "url": "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/icloud.txt",
        "path": "./ruleset/loyalsoldier/icloud.yaml"
    },
    "apple": {
        ...ruleProviderCommon,
        "behavior": "domain",
        "url": "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/apple.txt",
        "path": "./ruleset/loyalsoldier/apple.yaml"
    },
    "google": {
        ...ruleProviderCommon,
        "behavior": "domain",
        "url": "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/google.txt",
        "path": "./ruleset/loyalsoldier/google.yaml"
    },
    "proxy": {
        ...ruleProviderCommon,
        "behavior": "domain",
        "url": "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/proxy.txt",
        "path": "./ruleset/loyalsoldier/proxy.yaml"
    },
    "direct": {
        ...ruleProviderCommon,
        "behavior": "domain",
        "url": "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/direct.txt",
        "path": "./ruleset/loyalsoldier/direct.yaml"
    },
    "private": {
        ...ruleProviderCommon,
        "behavior": "domain",
        "url": "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/private.txt",
        "path": "./ruleset/loyalsoldier/private.yaml"
    },
    "gfw": {
        ...ruleProviderCommon,
        "behavior": "domain",
        "url": "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/gfw.txt",
        "path": "./ruleset/loyalsoldier/gfw.yaml"
    },
    "tld-not-cn": {
        ...ruleProviderCommon,
        "behavior": "domain",
        "url": "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/tld-not-cn.txt",
        "path": "./ruleset/loyalsoldier/tld-not-cn.yaml"
    },
    "telegramcidr": {
        ...ruleProviderCommon,
        "behavior": "ipcidr",
        "url": "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/telegramcidr.txt",
        "path": "./ruleset/loyalsoldier/telegramcidr.yaml"
    },
    "cncidr": {
        ...ruleProviderCommon,
        "behavior": "ipcidr",
        "url": "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/cncidr.txt",
        "path": "./ruleset/loyalsoldier/cncidr.yaml"
    },
    "lancidr": {
        ...ruleProviderCommon,
        "behavior": "ipcidr",
        "url": "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/lancidr.txt",
        "path": "./ruleset/loyalsoldier/lancidr.yaml"
    },
    "applications": {
        ...ruleProviderCommon,
        "behavior": "classical",
        "url": "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/applications.txt",
        "path": "./ruleset/loyalsoldier/applications.yaml"
    }
    
}

customRules = [
]

const rules = [
    ...customRules,
    // Loyalsoldier 规则集
    "RULE-SET,applications,DIRECT",
    "RULE-SET,private,DIRECT",
    "RULE-SET,reject,REJECT",
    "RULE-SET,icloud,DIRECT",
    "RULE-SET,apple,DIRECT",
    "RULE-SET,google,PROXY",
    "RULE-SET,proxy,PROXY",
    "RULE-SET,direct,DIRECT",
    "RULE-SET,lancidr,DIRECT,no-resolve",
    "RULE-SET,cncidr,DIRECT,no-resolve",
    "RULE-SET,telegramcidr,PROXY",
    "GEOIP,LAN,DIRECT,no-resolve",
    "GEOIP,CN,DIRECT,no-resolve",
    "MATCH,PROXY"
];


function main(config, profileName) {
    config["proxy-groups"] = [];
    var select = {
        name: "PROXY",
        type: "select",
        proxies: [],
    }
    select.proxies = config.proxies.map((proxy) => proxy.name);
    config["proxy-groups"].push(select)

    config["rule-providers"] = ruleProviders;
    config["rules"] = rules;

    return config;
}
```

### 其他常用软件代理规则

[Spotify-Ads](https://github.com/Isaaker/Spotify-AdsList)

```Json
// ruleProviders
"spotifyAds": {
    "type": "http",
    "format": "text",
    "interval": 86400,
    "behavior": "domain",
    "url": "https://raw.githubusercontent.com/Isaaker/Spotify-AdsList/main/Lists/pi-hole.txt",
    "path": "./ruleset/Isaaker/spotifyAds.text"
}

// rules
[
    "DOMAIN,login5.spotify.com,PROXY",
    "DOMAIN,spclient.wg.spotify.com,PROXY",
    "DOMAIN,open.spotify.com,PROXY",
    "DOMAIN,api-partner.spotify.com,PROXY",
    "DOMAIN,partners.wg.spotify.com,PROXY",
    "DOMAIN,api.spotify.com,PROXY",
    "DOMAIN,audio4-fa.scdn.co,PROXY",
    "DOMAIN,seektables.scdn.co,PROXY",
    "RULE-SET,spotifyAds,REJECT"
]
```


## 常见问题
### 未开启代理时无法访问域名 cdn.jsdelivr.net 

尝试将域名替换为 `testingcf.jsdelivr.net`

## 通过 Windows 热点共享 VPN 网络
Clash 开启 TUN 模式，在控制面板-网络与共享中心-更改适配器设置，选择 Clash 创建的网络，属性-共享，勾选“允许其他网络用户通过此计算机的网络连接”，下面选择电脑创建的热点网络