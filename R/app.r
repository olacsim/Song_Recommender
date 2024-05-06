# Define UI
ui <- fluidPage(
  theme = shinytheme("flatly"),
  tags$head(
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css"),
    tags$style(HTML(".btn-primary { border-radius: 20px; }"))
  ),
  titlePanel("Song Similarity Finder"),
  sidebarLayout(                        #Building sidebar panel
    sidebarPanel(
      width = 4,
      h4("Enter Song Details:"),
      textInput("song_title", "Song Title"),
      p("e.g.: Yellow, Livin' On A Prayer, Party In The U.S.A, etc", style = "color: #888; font-size: 12px;"),
      textInput("artist_name", "Artist Name"),
      p("e.g.: Red Hot Chili Peppers, Coldplay, Kings Of Leon, etc", style = "color: #888; font-size: 12px;"),
      br(),  # Add some space between inputs and button
      actionButton("calculate", "Find Similar Songs", class = "btn-primary"),
      br(),
      p("Spot-R-fi", style = "color: #888; font-size: 12px;")
    ),
    mainPanel(          # Building panel
      width = 8,
      h4("Similar Songs:", style = "color: #333;"),
      tableOutput("similar_songs")
    )
  )
)

# Define server logic
server <- function(input, output) {
  output$similar_songs <- renderTable({
    req(input$calculate)                                   # Ensure that the calculation button is pressed before executing
    similar_songs <- calc_cos_sim(input$song_title, input$artist_name)    # Calculate cosine similarity for input song details

    # Check the size of similar_songs
    if(nrow(similar_songs) > 1) {
      # Format the similarity column to include a percentage sign
      similar_songs$similarity <- paste0(similar_songs$similarity, "%")
    }

    return(similar_songs)
  })
}

# Run the application
shinyApp(ui = ui, server = server)