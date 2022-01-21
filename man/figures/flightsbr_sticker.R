library(hexSticker) # https://github.com/GuangchuangYu/hexSticker
library(ggplot2)
library(flightsbr)


# add special text font
library(sysfonts)
font_add_google(name = "Montserrat", family = "Montserrat")
#
# library(extrafont)
# font_import()
# extrafont::choose_font(fonts = 'Gothan')
# loadfonts(device = "win")


img <- "./man/figures/globe.png"

sticker(img,
        package="flightsbr", p_family='Montserrat', p_color = '#006890',  p_fontface='italic',
        p_size=20, p_y = 1.6, # package name size and position
        s_x=1.05, s_y=.94, s_width=0.69,  # image size and position
        h_fill="white", h_color="#006890", h_size = 2, # hexagon
        dpi=400, # resolution
        url = 'https://github.com/ipeaGIT/flightsbr',
        u_size=4, u_family='Montserrat', u_color = '#003E56', # url
        filename="man/figures/logo.png")  # output name

# globe dimensions 733L x 655A
.7 * 655 /733



# ### .svg
#
#
# sticker(img,
#         package="flightsbr", p_family='Montserrat', p_color = '#006890',  p_fontface='italic',
#         p_size=20, p_y = 1.6, # package name size and position
#         s_x=1.05, s_y=.94, s_width=0.69,  # image size and position
#         h_fill="white", h_color="#006890", h_size = 2, # hexagon
#         dpi=400, # resolution
#         url = 'https://github.com/ipeaGIT/flightsbr',
#         u_size=4, u_family='Montserrat', u_color = '#003E56', # url
#         filename="man/figures/logo.svg")  # output name
#


