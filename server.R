function(input, output, session){
  
  # Create a dataframe out of the form data, project detail only
  responseDF <- reactive({
    # set up dates chosen based on unknown tickboxes (TRUE/FALSE) and format YEAR-MONTH into a single string for each date
    if(input$startUnknown){startDate <- "unknown"}else{startDate <- paste(input$startYear,input$startMonth,sep="-")}
    if(input$endUnknown){endDate <- "unknown"}else{endDate <- paste(input$endYear,input$endMonth,sep="-")}
    # Create dataframe from responses
    data.frame(question1 = input$question1,
               question2 = input$question2,
               question3 = input$question3,
               summary1 = input$summary1,
               question4 = input$question4,
               question5 = input$question5,
               question6 = input$question6,
               optionSelected = input$optionsList,
               start_date = startDate,
               end_date = endDate,
               choiceset1 = formatListtoCSVString(input$choiceset1),
               choiceset2 = formatListtoCSVString(input$choiceset2),
               #last column is date of submission
               added = paste((format(Sys.time(),"%Y-%m-%d %H:%M:%S")),sep = " "),
               stringsAsFactors = FALSE
               )
    })

  
# Output transposed dataframe in the submission review pop up (modal)
  output$modalDataFrame <- shiny::renderTable({t(responseDF())}, rownames = TRUE, colnames = FALSE)
  
  # function for creating the pop up (modal) window as a confirmation screen for users submitting a project
  # Displays the data they have entered in a table and gives them a choice to submit or to cancel and edit
  dataModal <- function() {
    modalDialog(size = "l",title = "Thank you for your submission!",
                h4("Please review the details and confirm to save, or cancel to go back and edit."),
                shiny::tableOutput("modalDataFrame"),
                footer = tagList(
                  modalButton("Cancel"),
                  actionButton("confirmSubmit", "Confirm", class = "btn-success")
      )
    )
  }
  
  # Show modal when "Submit Project" button is pressed.
  observeEvent(input$submitSurvey, {
    showModal(dataModal())
  })
  
  # When user confirms submission, run save data routine and reset form fields ready for next submission
  observeEvent(input$confirmSubmit,
               {
                 # saves data using function from global.R
                 #saveDataPostgres(responseDF())
                 saveDataCSV(responseDF())
                 # closes pop up (modal)
                 removeModal()
                 # RESET THE FORM - Restores the default values for all the fields after a response is submitted
                 updateTextInput(session,"question1",value = "")
                 updateTextInput(session, "question2",value = "")
                 updateTextInput(session,"question3",value = "")
                 updateTextInput(session,"question4",value = "")
                 updateTextInput(session,"summary1",value = "")
                 updateTextInput(session,"question5",value = "")
                 updateTextInput(session,"question6",value = "")
                 updateRadioButtons(session,"options",selected = "Option 1")
                 updateSelectInput(session,"startYear",selected = format(Sys.time(),"%Y")) # resets year input to this year
                 updateSelectInput(session,"startMonth",selected = format(Sys.time(),"%b")) # resets month input to this month
                 updateSelectInput(session,"endYear",selected = format(Sys.time(),"%Y")) # resets month input to this month
                 updateSelectInput(session,"endMonth",selected = format(Sys.time(),"%b")) # resets month input to this month
                 updateCheckboxInput(session,"startUnknown",value = TRUE)
                 updateCheckboxInput(session,"endUnknown",value = TRUE)
                 updateCheckboxGroupInput(session,"choiceset1",selected = FALSE) # clears all checked boxes
                 updateCheckboxGroupInput(session,"choiceset2",selected = FALSE) # clears all checked boxes
               })
  
  observeEvent(input$refreshTable,
               # this is a simple data refresh to view the submitted responses.
               #{output$dataFrame <- DT::renderDataTable(loadDataPostgres(), rownames = FALSE)}
               {output$dataFrame <- DT::renderDataTable(loadDataCSV(), rownames = FALSE)}
  )
  
  observeEvent(input$startUnknown,
               {
                 if(input$startUnknown){
                   shinyjs::disable("startMonth")
                   shinyjs::disable("startYear")
                 }
                 else
                 {
                   shinyjs::enable("startMonth")
                   shinyjs::enable("startYear")
                 }
                 
               })
  
  observeEvent(input$endUnknown,
               {
                 if(input$endUnknown){
                   shinyjs::disable("endMonth")
                   shinyjs::disable("endYear")
                 }
                 else
                 {
                   shinyjs::enable("endMonth")
                   shinyjs::enable("endYear")
                 }
                 
               })
  # Input box max lengths set using shinyjs package
  shinyjs::runjs("$('#question1').attr('maxlength', 150)")
  shinyjs::runjs("$('#question2').attr('maxlength', 150)")
  shinyjs::runjs("$('#question3').attr('maxlength', 200)")
  shinyjs::runjs("$('#summary1').attr('maxlength', 500)")
  shinyjs::runjs("$('#question4').attr('maxlength', 200)")
  shinyjs::runjs("$('#question5').attr('maxlength', 50)")
  shinyjs::runjs("$('#question6').attr('maxlength', 50)")
  
  # Description popover for choiceset1 from shinyBS package
  addPopover(session, id = "choiceset1",title = "Choices 1 Detail",
             content = HTML(paste0(strong("Choice 1"),em(" - Description"),p(),
                                   strong("Choice 2"),em(" - Description"),p(),
                                   strong("Choice 3"),em(" - Description"),p(),
                                   strong("Choice 4"),em(" - Description"),p(),
                                   strong("Choice 5"),em(" - Description"),p(),
                                   strong("Choice 6"),em(" - Description"),p()
                                   )
                                   
             ),
             placement = 'top',
             options = list(container = "body")
  )
}
