box( # Themes and Focus box open
  tags$style(".popover{
            font-size: 12px;
          }"),
  status = "primary",
  collapsible = FALSE,
  solidHeader = TRUE,
  title = "Section 4 - Some Check Box Groups Inputs With Hover Over Info",
  width = 12,
  column( # sub column 1 open
    width = 6,
    checkboxGroupInput( # checkboxGroupInput 1
      "choiceset1",
      label = "Choice Set 1 - With Popover",
      choices = c(
        "Choice 1",
        "Choice 2",
        "Choice 3",
        "Choice 4",
        "Choice 5",
        "Choice 6")
    ) # checkboxGroupInput 1 close
  ), # sub column 1 close
  column( # sub column 2 open
    width = 6,
    checkboxGroupInput( # checkboxGroupInput 2
      "choiceset2",
      label = "Choice Set 2 - No Popover",
      choices = c(
        "Choice 1",
        "Choice 2",
        "Choice 3",
        "Choice 4",
        "Choice 5",
        "Choice 6"),
      inline = FALSE
    ), # checkboxGroupInput 2 close
    bsPopover("test","test") # strange behaviour, comment this out and server side bsPopover stops working
  )  # sub column 2 close
) # Themes and Focus box close