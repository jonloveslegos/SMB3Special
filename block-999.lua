local autoscroll = require("autoscroll")

function onTick()
    self.visible = false
    autoscroll.scrollRight(2)
end