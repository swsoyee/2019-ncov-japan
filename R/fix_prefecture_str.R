is_prefecture <- function(x) {
  sapply(x, 
         grepl, 
         x = "(?<=東京都|北海道|(大阪|京都)府|(青森|岩手|宮城|秋田|山形|福島|茨城|栃木|群馬|埼玉|千葉|神奈川|新潟|富山|石川|福井|山梨|長野|岐阜|静岡|愛知|三重|滋賀|兵庫|奈良|和歌山|鳥取|島根|岡山|広島|山口|徳島|香川|愛媛|高知|福岡|佐賀|長崎|熊本|大分|宮崎|鹿児島|沖縄)県)",
         simplify = TRUE,
         USE.NAMES = FALSE
  )
}

fix_prefecture_str <- function(x) {
  x %>% 
    sapply(
      function(x) {
        if (is_prefecture(x)) {
          if (grepl(x, "^京都")) {
            "京都府"
          } else {
            prefecture_set <- 
              c("北海道", "青森県", "岩手県", "宮城県", "秋田県", 
                "山形県", "福島県", "茨城県", "栃木県", "群馬県", 
                "埼玉県", "千葉県", "東京都", "神奈川県", "新潟県", 
                "富山県", "石川県", "福井県", "山梨県", "長野県", 
                "岐阜県", "静岡県", "愛知県", "三重県", "滋賀県", 
                "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県", 
                "鳥取県", "島根県", "岡山県", "広島県", "山口県", 
                "徳島県", "香川県", "愛媛県", "高知県", "福岡県", 
                "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", 
                "鹿児島県", "沖縄県")
            str_dist <- 
              adist(x,
                    prefecture_set) %>% 
              c()
            if (length(unique(str_dist)) == 1) {
              x
            } else {
              prefecture_set[which.min(str_dist)]
            }        
          }
          } else {
          x      
        }
      },
      simplify = TRUE,
      USE.NAMES = FALSE)
}

set_prefecture_fullnames <- function(data) {
  data %>% 
    setNames(fix_prefecture_str(names(data)))
}