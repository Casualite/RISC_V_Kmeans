.data
datax:.word 0,2,4,52,54,52,30,34,18
datay:.word 0,1,0,0,1,2,6,5,2
data_size:.byte 9
k:.byte 3
clusterx:.word 15,30,43
clustery:.word 3,2,3
cluster_dist:.word 0,0,0,0,0,0,0,0,0
cluster:.byte 0,0,0,0,0,0,0,0,0
cluster_sumx:.word 0,0,0
cluster_sumy:.word 0,0,0
cluster_sizes:.byte 0,0,0
epochs:.byte 5
.text
    la s0,datax
    la s1,datay
    lb s5,data_size
    la s2,clusterx
    la s3,clustery
    lb s4,k
    la s6,cluster
    la s7,cluster_dist
    la s8,cluster_sumx
    la s9,cluster_sumy
    la s10,cluster_sizes
    lb s11,epochs

main:
    add t0,x0,x0
    main_outer_loop:
        bne t0,s11,main_outer_skip
            j skip_outer
        main_outer_skip: addi t0,t0,1
        add t1,x0,x0
        add t2,x0,s0 #data x
        add t3,x0,s1 #data y
        add t4,x0,s6 #cluster

        main_inner_loop:
            bne t1,s5,main_inner_skip
                j skip_inner
            main_inner_skip: lw t5,0(t2)
            lw t6,0(t3)
            add a0,x0,t5
            add a1,x0,t6
            jal x1,closest
            sb a0,0(t4)
            addi t1,t1,1
            addi t2,t2,4
            addi t3,t3,4
            addi t4,t4,1
        j main_inner_loop
        skip_inner:jal x1,new_centroid_params
    j main_outer_loop
    skip_outer:j done

        
dist: #returns distance in a0
    sw x1,-28(x2) #store temoprary registers
    jal x1,store_temp #store temoprary registers
    lw x1,0(x2) #store temoprary registers
    sub t0,a2,a0
    sub t1,a3,a1
    mul t0,t0,t0
    mul t1,t1,t1
    add a0,t1,t0
    sw x1,0(x2) #load temoprary registers
    jal x1,load_temp #load temoprary registers
    lw x1,-28(x2) #load temoprary registers
    jalr x0,x1,0
    
min: # finds the minimum value and returns its index, arg mem loc in a0
    addi t0,x0,1 #counter
    add t1,x0,x0 #smallest index yet
    lw t2,0(a0) #smallest value yet
    addi a0,a0,4
    min_loop:
        bne t0,s4,min_skip
            j min_exit
        min_skip:
        lw  t3,0(a0)
        bge t3,t2,min_swap_skip
            add t2,x0,t3
            add t1,x0,t0
        min_swap_skip:addi a0,a0,4
        addi t0,t0,1
        j min_loop
    min_exit: add a0,x0,t1
    jalr x0,x1,0

store_temp:
    sw t0,0(x2)
    sw t1,-4(x2)
    sw t2,-8(x2)
    sw t3,-12(x2)
    sw t4,-16(x2)
    sw t5,-20(x2)
    sw t6,-24(x2)
    addi x2,x2,-28
    jalr x0,x1,0

load_temp:
    lw t6,4(x2)
    lw t5,8(x2)
    lw t4,12(x2)
    lw t3,16(x2)
    lw t2,20(x2)
    lw t1,24(x2)
    lw t0,28(x2)
    addi x2,x2,28
    jalr x0,x1,0
    
    
closest: # finds the closest centroid by index ,pass memory location of (pointx,pointy)
    sw x1,-28(x2) #store temoprary registers
    jal x1,store_temp #store temoprary registers
    lw x1,0(x2) #store temoprary registers
    add t0,x0,s2 #clusterx
    add t1,x0,s3 #clustery
    add t3,x0,x0 #counter
    add t6,x0,s7 #cluster_dist
    clo_loop:
        bne t3,s4,clo_skip
            j clo_exit
        clo_skip:lw t4,0(t0)
        lw t5,0(t1)
        add a2,x0,t4
        add a3,x0,t5
        sw x1,0(x2)
        sw a0,-4(x2)
        addi x2,x2,-8
        jal x1,dist
        addi x2,x2,8
        lw x1,0(x2)
        sw a0,0(t6)
        lw a0,-4(x2)
        addi t3,t3,1
        addi t0,t0,4
        addi t1,t1,4
        addi t6,t6,4
        j clo_loop
    clo_exit:add a0,x0,s7
        sw x1,0(x2)
        jal x1,min
        jal x1,load_temp #load temoprary registers
        lw x1,-28(x2) #load temoprary registers
        jalr x0,x1,0

reset: #resets cluster sum and size
    sw x1,-28(x2) #store temoprary registers
    jal x1,store_temp #store temoprary registers
    lw x1,0(x2) #store temoprary registers

    add t0,x0,x0
    add t1,x0,s8
    add t3,x0,s9
    add t2,x0,s10
    res_loop:
        bne t0,s4,res_skip
            j res_exit
        res_skip: 
        sw x0,0(t1)
        sw x0,0(t3)
        sb x0,0(t2)
        addi t0,t0,1
        addi t1,t1,4
        addi t3,t3,4
        addi t2,t2,1
    j res_loop
    res_exit:sw x1,0(x2) #load temoprary registers
    jal x1,load_temp #load temoprary registers
    lw x1,-28(x2) #load temoprary registers
    jalr x0,x1,0
    
new_centroid_params:
    sw x1,-28(x2) #store temoprary registers
    jal x1,store_temp #store temoprary registers
    lw x1,0(x2) #store temoprary registers

    add t0,x0,x0 #counter
    add t1,x0,s0 #datax
    add t2,x0,s1 #datay
    add t3,x0,s6 #clusters
    add t4,x0,s2 #clusterx
    add t5,x0,s3 #clustery
    addi t6,x0,4
    add a0,x0,x0 #reset arg
    add a1,x0,x0 #reset arg
    sw x1,0(x2)
    addi x2,x2,-4
    jal x1,reset
    addi x2,x2,4
    lw x1,0(x2)
    sw s11,0(x2)
    cen_loop:
        bne t0,s5,cen_skip
            j cen_exit
        cen_skip:addi t0,t0,1
        lw a2,0(t1) #datax
        lw a3,0(t2) #datay
        lb a4,0(t3) #cluster it belongs to
        mul a5,a4,t6 #get loc in cluster_sum
        add a0,s8,a5 #get loc in cluster_sumx
        add a1,s9,a5 #get loc in cluster_sumy
        add a5,s10,a4 #get loc in cluster_size
        lw a6,0(a0) #get sumx
        lw a7,0(a1) #get sumy
        lb s11,0(a5) #cluster size
        add a6,a6,a2 
        add a7,a7,a3
        addi s11,s11,1
        sw a6,0(a0)
        sw a7,0(a1)
        sb s11,0(a5)
        addi t1,t1,4
        addi t2,t2,4
        addi t3,t3,1
    j cen_loop
    cen_exit:
    lw s11,0(x2)
    sw x1,0(x2)
    jal x1,calc_centroids
    lw x1,0(x2)
    sw x1,0(x2) #load temoprary registers
    jal x1,load_temp #load temoprary registers
    lw x1,-28(x2) #load temoprary registers
    jalr x0,x1,0

calc_centroids:
    add t0,x0,x0
    add t1,x0,s2
    add t2,x0,s3
    add t4,x0,s8 #sum x
    add t5,x0,s9 #sum y
    add t6,x0,s10 #cluster_sizes
    calc_loop:
        bne t0,s4,calc_skip
            j calc_exit
        calc_skip:
        lw a0,0(t4)
        lw a1,0(t5)
        lb a2,0(t6)
        div a0,a0,a2
        div a1,a1,a2
        sw a0,0(t1)
        sw a1,0(t2)
        addi t1,t1,4
        addi t2,t2,4
        addi t4,t4,4
        addi t5,t5,4
        addi t6,t6,1
        addi t0,t0,1
    j calc_loop
    calc_exit: jalr x0,x1,0
done: 
    add t0,x0,x0
    add t1,x0,s2
    add t2,x0,s3
    done_loop:
        bne t0,s4,done_loop_skip
        j done_skip
        done_loop_skip: 
        lw t4,0(t1)
        lw t5,0(t2)
        addi t1,t1,4
        addi t2,t2,4
        addi t0,t0,1
        j done_loop
        
    done_skip: 
    jal x1, reset
    nop