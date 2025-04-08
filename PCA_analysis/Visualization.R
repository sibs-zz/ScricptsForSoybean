a = read.table("pca.txt",header = T)
cols = c( "landrace" = "blue","soja" = "green","gracilis"="purple","cultivar" = "red" )
library(ggplot2)
ggplot(a,aes(x=pc2,y=pc3,color = group))+
  geom_point(alpha=0.8,position = "jitter")+
  theme_classic()+
  theme(legend.title=element_blank())+
  theme(panel.grid.major =element_blank(),panel.grid.minor = element_blank(),panel.background = element_blank(),axis.line = element_line(colour = "black"))+
  theme(axis.text.x=element_text(size=13),axis.text.y=element_text(size = 13),axis.title.x = element_text(size = 18),axis.title.y = element_text(size = 18))+
  scale_color_manual(values=cols, aesthetics = c("colour","fill"))
