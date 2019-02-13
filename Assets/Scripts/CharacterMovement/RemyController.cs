﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RemyController : MonoBehaviour
{
    public static Vector3 destination;
    public static Vector3 lastPosition;
    public float rotationSpeed;
    public float movingSpeed;
    private Quaternion playerRot;
    private  Animator animator;
    private float timer;
    private float EPSSION;
    private float reLocateDelay;
    // Start is called before the first frame update
    void Start()
    {
        EPSSION = 0.0001f;
        reLocateDelay = 0.15f;
        timer = 0;
        rotationSpeed = 20;
        movingSpeed = 10;
        animator = GetComponent<Animator>();
        animator.SetBool("isRunning", false);
        destination = transform.position;
    }

    // Update is called once per frame
    void FixedUpdate()
    {

        DoNotFlay();
        Rotate();
        Move();
        //RemyDead();
        //lastPosition = transform.position;
        //SavePos();

    }

    void Rotate()
    {

            playerRot = Quaternion.LookRotation(destination);
            transform.rotation = Quaternion.Slerp(transform.rotation, playerRot, rotationSpeed * Time.deltaTime);


    }
    void Move()
    {
        Vector3 differ = transform.position - destination;
        if((differ.x > EPSSION || differ.x < -EPSSION) && (differ.z < -EPSSION || differ.z > EPSSION)) {
        //if (transform.position != destination) {
            animator.SetBool("isRunning", true);
            transform.position = Vector3.MoveTowards(transform.position, destination, movingSpeed * Time.deltaTime);  
        }
        else
        {
            animator.SetBool("isRunning", false);
        }
    }

    void DoNotFlay()
    {
        if (destination.y > transform.position.y)
        {
            destination.y = transform.position.y;
        }
    }

    void SavePos()
    {
        timer += Time.deltaTime;
        if (timer > reLocateDelay)
        {
            lastPosition = transform.position;
            timer = 0;
        }
    }

    void RemyDead()
    {
        if (Input.GetKey("D"))
        {
            animator.SetBool("isDead", true);
            destination = this.transform.position;
        }
    }
}
