﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class RangedEnemyController : EnemyController
{
    // Animator stuff
    private Animator animator;

    public const string AttackMode = "rangedAttack";

    private void Awake()
    {
        animator = GetComponent<Animator>();
    }

    protected override void Initialize()
    {
        // Set up animator
        //animator = GetComponent<Animator>();
        Debug.Log("animator = " + animator);
        animator.SetBool("meleeAttack", false);
        animator.SetBool("rangedAttack", false);

        // Default spawnPos and movingRange
        spawnPos = transform.position;
        movingRange = 20f;
        chaseSpeed = 15f;
        movable = true;

        // Default vision
        visionAngle = 60f;
        visionDistance = 20;
        attackDistance = 20f;
    }

    protected override void UniqueUpdate()
    {
        agent.isStopped = false;
        animator.SetBool("meleeAttack", false);
        animator.SetBool("rangedAttack", false);

        // By default, enemy is not attacking.
        attackController.SetAttack(AttackMode, false);
    }

    protected override void Attack(Vector3 playerPos)
    {
        // Look at target (player character)
        transform.rotation = Quaternion.LookRotation(new Vector3((
			playerPos - transform.position).x, 
			0.0f,
			(playerPos - transform.position).z));

        // Stop and attack target (player character)
        agent.isStopped = true;

        // Change to attack animation
        animator.SetBool(AttackMode, true);

        // Cause damage
        attackController.SetAttack(AttackMode, true);
    }

    protected override void UnderAttack()
    {
        // if (Input.GetMouseButtonDown(0))
        // {
        //     healthPoints--;
        //     animator.SetTrigger("hit");
        // }
    }

    public override IEnumerator Die()
    {
        Debug.Log("animator2 = " + animator);
        animator.SetTrigger("death");
        yield return new WaitForSeconds(0.5f);
        Destroy(gameObject);
    }
}
