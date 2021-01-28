### User Interface created using shinydashboard package

dashboardPage(skin = "blue",
  title = "Shiny Survey Form", # This is the title that appears in the browser tab name
  dashboardHeader(
    #Set height of dashboardHeader so that it fits A Logo
    tags$li(class = "dropdown",
           tags$style(".main-header {max-height: 100px}"),
           tags$style(".main-header .logo {height: 100px}")
    ),
    # Set logo as title and clickable link to a website
    # https://stackoverflow.com/questions/31440564/adding-a-company-logo-to-shinydashboard-header
    title = tags$a(href='https://shiny.rstudio.com/',
                  tags$img(src='shiny-og-fb.jpg'), # note, logo stored in www folder
                  target="_blank"), # opens the link in a new tab/window
    titleWidth = 230
  ),
  dashboardSidebar(
    disable = FALSE,
    sidebarMenu(
      br(),
      br(),
      br(),
      menuItem("Survey Form", tabName = "surveyForm", icon = icon("th")),
      menuItem("View Responses", tabName = "surveyTable", icon = icon("th"))
    )
  ),
  dashboardBody( # body open
    shinyjs::useShinyjs(),
    # set width of popover/information panels produced by shinyBS
    tags$style(".popover{
            max-width: 50%;
          }"),
    tabItems( # tabItems open
      tabItem( # tabItem 1
        tabName = "surveyForm",
        #customTheme, # sets custom colours as per CSS modifications, see global.R customTheme
        #shinyDashboardThemes("grey_light"), or set using prebuilt theme 
        fluidPage(
          h2("Title of Survey"),
          fluidRow(
            div(class = "col-sm-12 col-md-8 col-lg-6",
            column(
              width = 12,
              # block of text that includes links to other sites
              h4(HTML(paste0("Please fill out this survey, it'll really help us out. Built in ",a(href="https://shiny.rstudio.com/","R Shiny"),
                             "."))),
              br()
            ))
          ),
          fluidRow(
            div(class = "col-xs-12 col-sm-12 col-md-12 col-lg-5",
            box(
              # Project Detail box open
              status = "primary",
              collapsible = FALSE,
              solidHeader = TRUE,
              title = "Section 1",
              width = 12,
              textInput("question1", label = "Question 1"),
              bsTooltip("question1","Max 150 Characters", placement = "right"), # shinyBS tooltip indicating max field length. shinyjs used to limit field length
              textInput("question2", label = "Question 2"),
              bsTooltip("question2","Max 150 Characters", placement = "right"),
              textInput("question3", label = "Question 3"),
              bsTooltip("question3","Max 200 Characters", placement = "right"),
              textAreaInput("summary1", label = "Summary 1", height = "154px"),
              bsTooltip("summary1","Max 500 Characters", placement = "right"),
              textInput("question4", label = "Question 4"),
              bsTooltip("question4","Max 200 Characters", placement = "right")
            )), # Project Detail box close
            div(class = "col-xs-12 col-sm-12 col-md-12 col-lg-2",
            box( # Contact Detail box open
              status = "primary",
              collapsible = FALSE,
              solidHeader = TRUE,
              title = "Section 2",
              width = 12,
              textInput("question5", label = "Question 5"),
              bsTooltip("question5","Max 50 Characters", placement = "right"),
              textInput("question6", label = "Question 6"),
              bsTooltip("question6","Max 50 Characters", placement = "right")
            )), # Contact Detail box close
            
            # out sourced the last two sections to seperate files
            # div(class) lines are some CSS to ensure they look OK on smaller window sizes
            div(class = "col-xs-12 col-sm-12 col-md-12 col-lg-5",
            source("./section3.R",local = TRUE)$value
            ),
            div(class = "col-xs-12 col-sm-12 col-md-12 col-lg-7",
            source("./section4.R",local = TRUE)$value
            )
          ),
          column(
            width = 2,
            actionButton(
              "submitSurvey",
              "Submit Survey",
              width = 200,
              class = "btn-info btn-lg"
            )
          )
        )
      ), # tabItem 1 close
      tabItem( # tabItem 2
        tabName = "surveyTable",
        fluidRow(
          # View submitted responses
          box(
            status = "primary",
            collapsible = TRUE,
            solidHeader = TRUE,
            title = "Survey Responses",
            width = 12,
            actionButton(
              "refreshTable",
              "Refresh Table"
            ),
            DT::dataTableOutput("dataFrame")
            )
          )
        )  # tabItem 2 close
      ) # tabItems close
    ) # dashboardBody close
  ) # dashboardPage close
