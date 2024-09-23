# Clash 代理

## Clash for Windows 对订阅的源进行预处理

```yml
parsers: # array
  # - reg: ^.*$ 匹配所有订阅
  # - url: https://example.com/profile.yaml 指定订阅
  - reg: ^.*$

    code: |
      module.exports.parse = async (
          raw,
          { axios, yaml, notify, console },
          { name, url, interval, selected }
      ) => {
          const obj = yaml.parse(raw);
          # 删除服务商自带的策略组和规则
          obj["rules"] = [];
          obj["proxy-groups"] = [];
          # 添加一个包含所有线路的代理组
          var select = {
              name: "PROXY",
              type: "select",
              proxies: [],
          }
          select.proxies = obj.proxies.map((proxy) => proxy.name);
          obj["proxy-groups"].push(select)
          return yaml.stringify(obj);
      };
    yaml:
      prepend-rules: # 规则由上往下遍历，如上面规则已经命中，则不再往下处理
        - RULE-SET,applications,DIRECT
        - DOMAIN,clash.razord.top,DIRECT
        - DOMAIN,yacd.haishan.me,DIRECT
        - RULE-SET,private,DIRECT
        - RULE-SET,reject,REJECT
        - RULE-SET,icloud,DIRECT
        - RULE-SET,apple,DIRECT
        - RULE-SET,google,PROXY
        - RULE-SET,proxy,PROXY
        - RULE-SET,direct,DIRECT
        - RULE-SET,lancidr,DIRECT
        - RULE-SET,cncidr,DIRECT
        - RULE-SET,telegramcidr,PROXY
        - GEOIP,LAN,DIRECT
        - GEOIP,CN,DIRECT
        - MATCH,PROXY

      # 添加规则集
      mix-rule-providers:
        reject:
          type: http
          behavior: domain
          url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/reject.txt"
          path: ./ruleset/reject.yaml
          interval: 86400

        icloud:
          type: http
          behavior: domain
          url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/icloud.txt"
          path: ./ruleset/icloud.yaml
          interval: 86400

        apple:
          type: http
          behavior: domain
          url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/apple.txt"
          path: ./ruleset/apple.yaml
          interval: 86400

        google:
          type: http
          behavior: domain
          url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/google.txt"
          path: ./ruleset/google.yaml
          interval: 86400

        proxy:
          type: http
          behavior: domain
          url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/proxy.txt"
          path: ./ruleset/proxy.yaml
          interval: 86400

        direct:
          type: http
          behavior: domain
          url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/direct.txt"
          path: ./ruleset/direct.yaml
          interval: 86400

        private:
          type: http
          behavior: domain
          url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/private.txt"
          path: ./ruleset/private.yaml
          interval: 86400

        gfw:
          type: http
          behavior: domain
          url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/gfw.txt"
          path: ./ruleset/gfw.yaml
          interval: 86400

        tld-not-cn:
          type: http
          behavior: domain
          url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/tld-not-cn.txt"
          path: ./ruleset/tld-not-cn.yaml
          interval: 86400

        telegramcidr:
          type: http
          behavior: ipcidr
          url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/telegramcidr.txt"
          path: ./ruleset/telegramcidr.yaml
          interval: 86400

        cncidr:
          type: http
          behavior: ipcidr
          url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/cncidr.txt"
          path: ./ruleset/cncidr.yaml
          interval: 86400

        lancidr:
          type: http
          behavior: ipcidr
          url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/lancidr.txt"
          path: ./ruleset/lancidr.yaml
          interval: 86400

        applications:
          type: http
          behavior: classical
          url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/applications.txt"
          path: ./ruleset/applications.yaml
          interval: 86400
```
