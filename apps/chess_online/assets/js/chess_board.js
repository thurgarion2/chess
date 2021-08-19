import { range } from './helpers'

let Chessboard = {
    pieces: [],
    valid_moves: [],
    state: undefined,
    channel: undefined,
    selected: undefined,
    element: undefined,


    init(channel, element) {
        if (!element) { return }

        this.element = element
        this.channel = channel

        this.set_up()
    },

    set_up() {
        this.element.appendChild(this.create_board())

        this.channel.on("play", resp => {
            console.log(resp)
            this.state = "play"
            this.update_board(resp)
        })

        this.channel.on("wait", resp => {
            console.log(resp)
            this.state = "wait"
            this.update_board(resp)
        })
    },

    update_board(resp) {
        this.reset_chess_pieces()

        this.pieces = resp.board
        this.valid_moves = resp.valid_moves

        this.draw_chess_pieces()

    },

    create_board() {
        let board = document.createElement('table');
        board.classList.add('board')
        range(0, 7).reverse().forEach(y => board.appendChild(this.create_line(y)))
        return board
    },

    create_line(y) {
        let line = document.createElement('tr')
        line.classList.add('board_line')
        range(0, 7).forEach(x => line.appendChild(this.create_tile(x, y)))
        return line
    },

    create_tile(x, y) {
        let tile = document.createElement('th')
        tile.classList.add(this.class_of_tile(x, y))
        tile.id = this.coord_to_id(x, y)

        tile.addEventListener("click", e => this.update_state(x, y))
        return tile
    },

    update_state(x, y) {
        console.log(`from state ${this.state}`)
        switch (this.state) {
            case "wait":
                break;
            case 'play':
                let valid_tile_moves = this.valid_moves[this.coord_to_id(x, y)]

                if (valid_tile_moves) {
                    this.state = "selected"
                    this.selected = [x, y]
                    this.draw_valid_moves(valid_tile_moves)
                }

                break;
            case 'selected':
                //changer les nom valid moves !!!!!
                const [x_s, y_s] = this.selected
                const curr_id = this.coord_to_id(x, y)

                valid_tile_moves = this.valid_moves[this.coord_to_id(x_s, y_s)]
                this.reset_valid_moves(valid_tile_moves)


                if (valid_tile_moves.includes(curr_id)) {
                    this.state = "played"
                    this.reset_valid_moves(valid_tile_moves)
                    this.send_move([x_s, y_s], [x, y])
                } else if (curr_id in this.valid_moves) {
                    this.selected = [x, y]
                    this.reset_valid_moves(valid_tile_moves)
                    this.draw_valid_moves(this.valid_moves[curr_id])
                } else {
                    this.state = "play"
                }

                break;
            case 'played':
                //we wait for server response
                break;
        }
        console.log(`to state ${this.state}`)

    },

    send_move(from, to) {
        this.channel.push("play", { from: from, to: to })
            .receive("error", e => console.log(e))
    },

    //to all this methods
    reset_valid_moves(valid_moves) {
        valid_moves.forEach(coord => this.reset_valid_move(coord))
    },

    reset_valid_move(coord) {
        const tile = document.getElementById(coord)
        if (!tile) { return }
        tile.classList.remove("selected")
    },

    draw_valid_moves(valid_moves) {
        valid_moves.forEach(coord => this.draw_valid_move(coord))
    },

    draw_valid_move(coord) {
        const tile = document.getElementById(coord);
        if (!tile) { return }
        tile.classList.add("selected")
    },

    coord_to_id(x, y) {
        return `${x},${y}`
    },

    draw_chess_pieces() {
        Object.entries(this.pieces).forEach(entry => {
            const [coord, piece] = entry
            this.draw_chess_piece(coord, piece)
        })
    },

    draw_chess_piece(coord, piece) {
        const tile = document.getElementById(coord)

        const img = document.createElement("img")
        img.src = this.img_piece(piece.piece, piece.color)

        tile.appendChild(img)

    },

    img_piece(piece, color){
        let col = ""

        if (color == "white") {
            col = "w"
        } else {
            col = "b"
        }

        return `/images/chess_pieces/${col}_${piece.toLowerCase()}_1x.png`
    },

    reset_chess_pieces() {
        Object.entries(this.pieces).forEach(entry => {
            const [coord, piece] = entry
            this.reset_chess_piece(coord, piece)
        })
    },

    reset_chess_piece(coord, piece) {
        const tile = document.getElementById(coord)
        while(tile.firstChild){tile.removeChild(tile.firstChild)}
    },

    class_of_tile(x, y) {
        if ((x + y) % 2 == 0) { return "black_tile" } else { return "white_tile" }
    }

}

export default Chessboard