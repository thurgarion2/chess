import chessboard from "./chess_board"

let load_game = {
    init(socket, element){
        if(!element){return}
        console.log("init")
        socket.connect()

        this.channel = socket.channel("chess_game:lobby", {})

        this.channel.join()
            .receive("ok", resp => {
                console.log("Joined successfully", resp)
                this.waiting(element)
            })
            .receive("error", resp => { console.log("Unable to join", resp) })

        this.channel.on("found adversary", resp => {
            this.create_game(this.channel, element, resp.color)
        })

        this.channel.onError( () => {
            this.channel.leave()
            this.error_message(element)
        } )
    },

    waiting(element){
       
        element.innerHTML = `
        <div class="waiting">
            <svg class="waiting_spinner" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            <div class="waiting_text">
                Searching a game
            </div>
        </div>
      `;
    },

    create_game(channel, element, color){
    
        this.clear(element)
        let el = document.createElement("p")
        el.textContent = `your are the ${color} player`
        element.appendChild(el)
        chessboard.init(channel, element)
    },

    error_message(element){
        this.clear(element)
        let el = document.createElement("p")
        el.textContent ="Oops there was an error ! Start a new game"
        element.appendChild(el)
    },
    clear(element){
        while(element.firstChild){ element.removeChild(element.firstChild) }
    }


}

export default load_game