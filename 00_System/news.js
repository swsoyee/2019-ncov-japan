(function() {
    const regionArray = [
        "北海道",
        "青森",
        "岩手",
        "宮城",
        "秋田",
        "山形",
        "福島",
        "茨城",
        "栃木",
        "群馬",
        "埼玉",
        "千葉",
        "東京",
        "神奈川",
        "新潟",
        "富山",
        "石川",
        "福井",
        "山梨",
        "長野",
        "岐阜",
        "静岡",
        "愛知",
        "三重",
        "滋賀",
        "京都",
        "大阪",
        "兵庫",
        "奈良",
        "和歌山",
        "鳥取",
        "島根",
        "岡山",
        "広島",
        "山口",
        "徳島",
        "香川",
        "愛媛",
        "高知",
        "福岡",
        "佐賀",
        "長崎",
        "熊本",
        "大分",
        "宮崎",
        "鹿児島",
        "沖縄",
        "空港",
    ];

    const result = [];
    setTimeout(function() {
        $('div.content--items>ul.content--list.grid--col-single>li>a').each((index, item) => {
            const url = `https://www3.nhk.or.jp${$(item).attr('href').split('?')[0]}`;
            const title = $(item).find('dl>dd>em').text();
            const region = regionArray[regionArray.findIndex(pref => title.includes(pref))];
            const time = $(item).find('dl>dd>time').attr('datetime').substr(0,10).replaceAll('-', '');
            if ( region !== undefined ) {
                if ( region === '空港' ) {
                    result.push(["00000", time, title, url, '検疫職員', '日本'].join(','));
                } else {
                    result.push(["00000", time, title, url, region, '日本'].join(','));
                }
            }
        })
        navigator.clipboard.writeText(result.join('\n')).then(function() {
            console.log('Copying to clipboard was successful!');
        }, function(err) {
            console.error('Could not copy text: ', err);
        });
    }, 2000);
})();
