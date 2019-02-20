﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RemyMovement : MonoBehaviour
{
    public static Vector3 initialPosition;
    public static Vector3 destination;
    public static Vector3 lastDestination;

    public float rotationSpeed;
    public float movingSpeed;
    private Quaternion playerRot;
    private Animator animator;
    private float timer;
    private float EPSSION;
    private float reLocateDelay;
    private Vector3 lookAtTarget;
    // Start is called before the first frame update
    void Start()
    {
        initialPosition = new Vector3(5, 5, 5);
        EPSSION = 0.0001f;
        reLocateDelay = 0.15f;
        timer = 0;
        rotationSpeed = 20;
        movingSpeed = 10;
        animator = GetComponent<Animator>();
        animator.SetBool("isRunning", false);
        this.transform.position = initialPosition;
        //destination = initialPosition;
    }

    //TODO: DELETE THIS AND FIX IN GENERATEISLAND
    public void setDetination(Vector3 Destination)
    {
        destination = Destination;
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        DoNotFly();

        DoNotShake();

        Rotate();

        Move();

        //SavePos();

    }

    void Rotate()
    {
        if (transform.position != destination) {
            lookAtTarget = destination - transform.position;
            playerRot = Quaternion.LookRotation(lookAtTarget);
            transform.rotation = Quaternion.Slerp(transform.rotation, playerRot, rotationSpeed * Time.deltaTime);
        }
        else
        {
            lookAtTarget = transform.position;
        }
    }
    void Move()
    {
        Vector3 differ = transform.position - destination;
        if((differ.x > EPSSION || differ.x < -EPSSION) && (differ.z < -EPSSION || differ.z > EPSSION)) {
            //if (transform.position != destination) {

            animator.SetBool("isIdleToMelee", false);

            animator.SetBool("isFireballIgnite", false);

            animator.SetBool("isFireballVolley", false);

            animator.SetBool("isRunning", true);

            transform.position = Vector3.MoveTowards(transform.position, destination, movingSpeed * Time.deltaTime);  
        }
        else
        {
            animator.SetBool("isRunning", false);
        }
    }

    void DoNotFly()
    {
        destination.y = transform.position.y;
    }

    void DoNotShake()
    {
        if (Vector3.Distance(destination, this.transform.position) < 1.0f)
        {
            destination = this.transform.position;
        }
    }

    //void SavePos()
    //{
    //    timer += Time.deltaTime;
    //    if (timer > reLocateDelay)
    //    {
    //        lastPosition = transform.position;
    //        timer = 0;
    //    }
    //}

}
