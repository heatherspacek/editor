package editre

import SDL "vendor:sdl3"

colour :: [3]u8

col_nord00 :: colour{46, 52, 64}
col_nord01 :: colour{59, 66, 82}
col_nord02 :: colour{67, 76, 94}
col_nord03 :: colour{76, 86, 106}
// ^ darks
col_nord04 :: colour{216, 222, 233}
col_nord05 :: colour{229, 233, 240}
col_nord06 :: colour{236, 239, 244}
// ^ lights
col_nord07 :: colour{143, 188, 187}
col_nord08 :: colour{136, 192, 208}
col_nord09 :: colour{129, 161, 193}
col_nord10 :: colour{94, 129, 172}
// ^ blues
col_nord11 :: colour{191, 97, 106}
col_nord12 :: colour{208, 135, 112}
col_nord13 :: colour{235, 203, 139}
col_nord14 :: colour{163, 190, 140}
col_nord15 :: colour{180, 142, 173}
// ^ accents

col_bg :: col_nord00
col_lineactive :: col_nord04
col_red :: col_nord11

paintwith :: proc(col: colour) {
    SDL.SetRenderDrawColor(ctx.renderer, col[0], col[1], col[2], 0xff)
}
