//
//  ViewController.swift
//  tictactoe
//
//  Created by IDDT on 4/3/17.
//

import UIKit

class ViewController: UIViewController {
    
    var human_symbol = "X"
    var cpu_symbol = "O"
    var game_on = true
    var cpu_move_count = 0
    var central_taken = false
    var grid: [[String]] = [
        ["#","#","#"],
        ["#","#","#"],
        ["#","#","#"]
    ]
    
    let combinations = [
        [[0, 0], [0, 1], [0, 2]],
        [[1, 0], [1, 1], [1, 2]],
        [[2, 0], [2, 1], [2, 2]],
        
        [[0, 0], [1, 0], [2, 0]],
        [[0, 1], [1, 1], [2, 1]],
        [[0, 2], [1, 2], [2, 2]],
        
        [[0, 0], [1, 1], [2, 2]],
        [[0, 2], [1, 1], [2, 0]]
    ]
    
        
    // Absolutely random move in free cell.
    func get_random_move() -> [Int] {
        var moveFound = false
        var y:Int?
        var x:Int?
        while moveFound == false {
            let a:UInt32 = arc4random_uniform(3)
            let b:UInt32 = arc4random_uniform(3)
            let symbol = grid[Int(a)][Int(b)]
            if symbol == "#" {
                moveFound = true
                y = Int(a)
                x = Int(b)
            }
        }
        return([y!, x!])
    }
        
        
    // Cells that are endangered or in criticl condition.
    func get_potential_cells() -> [[Int]] {
        
        // Categorizing the winning combinations.
        var warning: [Int] = []
        var danger: [Int] = []
        for (r, row) in self.combinations.enumerated() {
            var empty_count = 0
            var enemy_count = 0
            var own_count = 0
            for c in row {
                let cell:String = grid[c[0]][c[1]]
                if cell == "#" {
                    empty_count += 1
                } else if cell == human_symbol {
                    enemy_count += 1
                } else if cell == cpu_symbol {
                    own_count += 1
                }
            }
            if enemy_count == 2 && empty_count == 1 {
                danger.append(r)
            } else if enemy_count == 1 && own_count == 0 {
                warning.append(r)
            }
        }
        
        // Assigning the array.
        var array:[Int] = []
        if danger.count > 0 {
            array = danger
        } else if warning.count > 0 {
            array = warning
        }
        
        // Convert combinations into cells
        var cells:[[Int]] = []
        if array.count > 0 {
            for item in array {
                for cell in self.combinations[item] {
                    cells.append(cell)
                }
            }
        }
        return(cells)
    }
    func get_most_frequent(potential_cells:[[Int]]) -> [[Int]] {
        // Find max frequency
        var maxFrequency = 0
        for cell in potential_cells {
            var frequency = 0
            for cell_2 in potential_cells {
                if cell_2 == cell {
                    frequency += 1
                }
            }
            if frequency >= maxFrequency {
                maxFrequency = frequency
            }
        }
        // Get most frequent items
        var frequent_cells:[[Int]] = []
        for cell in potential_cells {
            var count = 0
            for cell_2 in potential_cells {
                if cell_2 == cell {
                    count += 1
                }
            }
            if count >= maxFrequency {
                frequent_cells.append(cell)
            }
        }
        return(frequent_cells)
    }
        
    
    // Functions to handle the second move. (Part 1)
    func get_cells_taken_by_enemy(enemy_symbol:String) -> [[Int]] {
        var taken:[[Int]] = []
        for y in 0...2 {
            for x in 0...2 {
                if grid[y][x] == enemy_symbol {
                    taken.append([y, x])
                }
            }
        }
        return(taken)
    }
    func get_adjoining_cells(cells:[[Int]]) -> [[Int]] {
        var output:[[Int]] = []
        for item in cells {
            let y = item[0]
            let x = item[1]
            output.append([y+1, x])
            output.append([y-1, x])
            output.append([y, x+1])
            output.append([y, x-1])
        }
        return(output)
    }
    
    
    // General functions
    func get_cells_from_both_arrays(arr_1:[[Int]], arr_2:[[Int]]) -> [[Int]] {
        var output:[[Int]] = []
        for item_1 in arr_1 {
            for item_2 in arr_2 {
                if item_1 == item_2 {
                    output.append(item_1)
                }
            }
        }
        return(output)
    }
    func get_random_cell(array:[[Int]]) -> [Int] {
        let rand:UInt32 = arc4random_uniform(UInt32(array.count))
        return(array[Int(rand)])
    }
    func filter_out_taken(cells:[[Int]]) -> [[Int]] {
        // Find all taken cells.
        var taken:[[Int]] = []
        for y in 0...2 {
            for x in 0...2 {
                if grid[y][x] != "#" {
                    taken.append([y, x])
                }
            }
        }
        
        var new_array:[[Int]] = []
        for cell in cells {
            var cell_is_taken = false
            for taken_cell in taken {
                if cell == taken_cell {
                    cell_is_taken = true
                    break
                }
            }
            if cell_is_taken == false {
                new_array.append(cell)
            }
        }
        return(new_array)
    }
    
    
    // Returns a cell if possible to win in one move, otherwise nil.
    func if_possible_to_win(own_symbol:String) -> [Int]? {
        
        var combination:[[Int]] = []
        
        for row in combinations {
            var own_cells = 0
            var empty_cells = 0
            for i in row {
                switch grid[i[0]][i[1]] {
                case own_symbol:
                    own_cells += 1
                case "#":
                    empty_cells += 1
                default:
                    break
                }
            }
            if own_cells == 2 && empty_cells == 1 {
                combination = row
                break
            }
        }
        
        if combination.count != 0 {
            for c in combination {
                if grid[c[0]][c[1]] == "#" {
                    return(c)
                }
            }
        }
        return(nil)
    }
        

    func get_random_free_corner() -> [Int]? {
        let corners = [
            [0, 0],
            [0, 2],
            [2, 0],
            [2, 2]
        ]
        let free_corners = filter_out_taken(cells: corners)
        if free_corners.count > 0 {
            return(get_random_cell(array: free_corners))
        }
        return(nil)
    }
    func get_first_taken_corner(enemy_symbol:String) -> [Int]? {
        let corners = [
            [0, 0],
            [0, 2],
            [2, 0],
            [2, 2]
        ]
        for corner in corners {
            if grid[corner[0]][corner[1]] == enemy_symbol {
                return(corner)
            }
        }
        return(nil)
    }
    func get_opposite_free_corner(cell:[Int]) -> [Int]? {
        let corners = [
            [0, 0],
            [0, 2],
            [2, 0],
            [2, 2]
        ]
        let opposites = [
            [2, 2],
            [2, 0],
            [0, 2],
            [0, 0]
        ]
        var opposite_corner:[Int] = []
        for (c, corner) in corners.enumerated() {
            if corner == cell {
                opposite_corner = opposites[c]
            }
        }
        if opposite_corner.count > 0 && grid[opposite_corner[0]][opposite_corner[1]] == "#" {
            return(opposite_corner)
        }
        return(nil)
    }
        
        
    // Choose move.
    func choose_move() -> [Int] {
        
        let potential_cells = filter_out_taken(cells: get_potential_cells())
        let most_frequent = get_most_frequent(potential_cells: potential_cells)
        
        // Check if possible to win in one move.
        let last_move = if_possible_to_win(own_symbol: cpu_symbol)
        if last_move != nil {
            return(last_move)!
        }
        
        // Conditions for the first move.
        if cpu_move_count == 0 {
            cpu_move_count += 1
            if grid[1][1] == "#" {
                return([1, 1])
            } else {
                central_taken = true
                return(get_random_free_corner())! // Never nil!
            }
        }
        // Conditions for the second move
        else if cpu_move_count == 1 {
            cpu_move_count += 1
            if central_taken == true {
                let taken_corner = get_first_taken_corner(enemy_symbol: human_symbol)
                if taken_corner != nil {
                    let opposite_corner = get_opposite_free_corner(cell: taken_corner!)
                    if opposite_corner != nil {
                        return(opposite_corner)!
                    }
                    return(get_random_free_corner())! // Never nil!
                }
            }
            
            let adj = get_adjoining_cells(cells: get_cells_taken_by_enemy(enemy_symbol: human_symbol))
            let cells = filter_out_taken(cells: adj)
            let array_1 = get_cells_from_both_arrays(arr_1: cells, arr_2: potential_cells)
            let array_2 = get_cells_from_both_arrays(arr_1: array_1, arr_2: most_frequent)
            if array_2.count > 0 {
                return(get_random_cell(array: array_2))
            } else if array_1.count > 0 {
                return(get_random_cell(array: array_1))
            } else {
                return(get_random_move())
            }
        }
        // Third move and after.
        else if most_frequent.count > 0 {
            cpu_move_count += 1
            return(get_random_cell(array: most_frequent))
        } else if potential_cells.count > 0 {
            cpu_move_count += 1
            return(get_random_cell(array: potential_cells))
        } else {
            cpu_move_count += 1
            return(get_random_move())
        }
    }
    func make_move() {
        if game_on == false {
            return
        }
        let move = choose_move()
        grid[move[0]][move[1]] = "O"
        update_grid()
        if_game_over()
    }
    
    func update_grid() {
        for (index, item) in (grid[0]+grid[1]+grid[2]).enumerated() {
            
            var symbol: String
            if item == "#" {
                symbol = ""
            } else {
                symbol = item
            }
            
            let button = self.view.viewWithTag(index+1) as! UIButton
            button.setTitle(symbol, for: .normal)
        }
    }
    func if_game_over() {
        var winner:String?
        
        let combinations = [
            grid[0],
            grid[1],
            grid[2],
            
            [grid[0][0], grid[1][0], grid[2][0]],
            [grid[0][1], grid[1][1], grid[2][1]],
            [grid[0][2], grid[1][2], grid[2][2]],
            
            [grid[0][0], grid[1][1], grid[2][2]],
            [grid[0][2], grid[1][1], grid[2][0]]
        ]
        for item in combinations {
            var X = 0
            var O = 0
            for symbol in item {
                if symbol == "X" {
                    X += 1
                }
                if symbol == "O" {
                    O += 1
                }
            }
            if X == 3 {
                game_on = false
                winner = "X"
                messageLabel.text = winner! + " won"
                return
            }
            if O == 3 {
                game_on = false
                winner = "O"
                messageLabel.text = winner! + " won"
                return
            }
        }
        // Checking if there free spaces left
        var freeCellCounter: Int = 0
        for item in grid[0]+grid[1]+grid[2] {
            if item == "#" {
                freeCellCounter += 1
            }
        }
        if freeCellCounter == 0 {
            game_on = false
            messageLabel.text = "No winner"
        }
        
    }
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBAction func gridButton(_ sender: UIButton) {
        if game_on == false {
            return
        }
        
        var y:Int?
        var x:Int?
        
        let tag = sender.tag
        if [1, 2, 3].contains(tag) {
            y = 0
            x = tag - 1
        }
        else if [4, 5, 6].contains(tag) {
            y = 1
            x = tag - 4
        }
        else if [7, 8, 9].contains(tag) {
            y = 2
            x = tag - 7
        }
        
        if grid[y!][x!] == "#" {
            grid[y!][x!] = human_symbol
        } else {
            return
        }
        
        update_grid()
        if_game_over()
        make_move()
    }
    
    
    @IBAction func resetButton(_ sender: UIButton) {
        grid = [["#","#","#"], ["#","#","#"], ["#","#","#"]]
        update_grid()
        messageLabel.text = ""
        game_on = true
        cpu_move_count = 0
        central_taken = false
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        update_grid()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

