# ADV7125 Color Bar Test - ISE Tcl Script
# Usage: xtclsh adv7125_colorbar.tcl [run|clean|help]

proc print_help {} {
    puts "ADV7125 VGA Color Bar Test - Tcl Control Script"
    puts ""
    puts "Usage: xtclsh adv7125_colorbar.tcl [command]"
    puts ""
    puts "Commands:"
    puts "  run     - Run full implementation flow"
    puts "  clean   - Clean all generated files"
    puts "  help    - Show this help message"
    puts ""
}

# 项目配置
set PROJECT_NAME "adv7125_colorbar"
set DEVICE "xc6slx45-3-fgg484"
set TOP_MODULE "adv7125_colorbar_top"

# 获取脚本所在目录
set SCRIPT_DIR [file dirname [info script]]
set PROJECT_DIR [file normalize $SCRIPT_DIR]

# 创建项目
proc create_project {} {
    global PROJECT_NAME DEVICE TOP_MODULE PROJECT_DIR
    
    # 创建新项目
    project new "${PROJECT_DIR}/${PROJECT_NAME}.xise"
    
    # 设置项目属性
    project set family "Spartan6"
    project set device $DEVICE
    project set top_module $TOP_MODULE
    
    # 添加源文件
    project add file "${PROJECT_DIR}/src/adv7125_colorbar_top.v"
    project add file "${PROJECT_DIR}/src/vga_colorbar_800x600.v"
    project add file "${PROJECT_DIR}/src/clk_wiz_50to40.v"
    project add file "${PROJECT_DIR}/../../src/video/adv7125_driver.v"
    
    # 添加约束文件
    project add file "${PROJECT_DIR}/constraints/adv7125_colorbar.ucf"
    
    # 保存项目
    project save
    
    puts "Project created: ${PROJECT_DIR}/${PROJECT_NAME}.xise"
}

# 运行实现流程
proc run_implementation {} {
    global PROJECT_NAME
    
    # 打开项目
    project open "${PROJECT_NAME}.xise"
    
    # 运行综合
    puts "Running synthesis..."
    process run "Synthesize - XST"
    
    # 检查综合结果
    if {[process get_status "Synthesize - XST"] != "PASSED"} {
        puts "ERROR: Synthesis failed!"
        return 1
    }
    
    # 运行实现
    puts "Running implementation..."
    process run "Implement"
    
    # 检查实现结果
    if {[process get_status "Implement"] != "PASSED"} {
        puts "ERROR: Implementation failed!"
        return 1
    }
    
    # 生成比特流
    puts "Generating bitstream..."
    process run "Generate Programming File"
    
    # 检查结果
    if {[process get_status "Generate Programming File"] != "PASSED"} {
        puts "ERROR: Bitstream generation failed!"
        return 1
    }
    
    puts ""
    puts "========================================"
    puts "Build completed successfully!"
    puts "Bitstream: implementation/${PROJECT_NAME}.bit"
    puts "========================================"
    
    return 0
}

# 清理项目
proc clean_project {} {
    global PROJECT_NAME PROJECT_DIR
    
    puts "Cleaning project..."
    
    # 删除生成的文件
    file delete -force "${PROJECT_DIR}/${PROJECT_NAME}"
    file delete -force "${PROJECT_DIR}/${PROJECT_NAME}.xise"
    file delete -force "${PROJECT_DIR}/${PROJECT_NAME}_xst"
    file delete -force "${PROJECT_DIR}/${PROJECT_NAME}.ngd"
    file delete -force "${PROJECT_DIR}/${PROJECT_NAME}.ncd"
    file delete -force "${PROJECT_DIR}/${PROJECT_NAME}.pcf"
    file delete -force "${PROJECT_DIR}/${PROJECT_NAME}.bit"
    file delete -force "${PROJECT_DIR}/${PROJECT_NAME}.gnat"
    
    puts "Clean completed."
}

# 主程序
set argc_new [llength $argv]
set argv_new $argv

if {$argc_new == 0} {
    # 默认：创建项目并运行
    if {![file exists "${PROJECT_DIR}/${PROJECT_NAME}.xise"]} {
        create_project
    }
    run_implementation
} elseif {$argc_new == 1} {
    set command [lindex $argv_new 0]
    
    switch $command {
        "run" {
            if {![file exists "${PROJECT_DIR}/${PROJECT_NAME}.xise"]} {
                create_project
            }
            run_implementation
        }
        "clean" {
            clean_project
        }
        "help" {
            print_help
        }
        default {
            puts "Unknown command: $command"
            print_help
            exit 1
        }
    }
} else {
    print_help
    exit 1
}
