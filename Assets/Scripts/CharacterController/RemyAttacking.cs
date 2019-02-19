﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RemyAttacking : MonoBehaviour
{
    public static Vector3 attackDirection;
    public static CCC.Abilities.Ability ability;
    


    private Animator animator;
    private string ablilityName;
    private Vector3 lookAtEnemy;
    private float EPSSION;
    private Vector3 lastDestination;

    public GameObject swordOnHand;
    public GameObject swordOnBack;


    // Start is called before the first frame update
    void Start()
    {
        animator = GetComponent<Animator>();
        ablilityName = ability.name;
        EPSSION = 0.001f;
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        MeleeAttack();
        if (ShouldEquip())
        {
            EquipSword();
        }

        //if (StopMeleeAttack())
        //{
        //    animator.SetBool("isUnEquip", true);
        //}

        //if (ShouldUnEquip())
        //{
        //    UnEquipSword();
        //}

        MagicAttack();

    }

    void MeleeAttack()
    {
        if (Input.GetButton("MeleeAttackTest"))
        {
            RotateToEnemy();
            animator.SetBool("isIdleToMelee", true);
        }
    }

    void MagicAttack()
    {

        if (Input.GetButton("MagicAttackTest"))
        {
            RotateToEnemy();
            //Debug.Log("abilityName: " + ablilityName);
            //Debug.Log("attackDirection: " + attackDirection);
            animator.SetBool("isIdleToMagic", true);
        }
    }

    void RotateToEnemy()
    {
        if (transform.position != attackDirection)
        {
            lookAtEnemy = attackDirection - transform.position;
  
            transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(lookAtEnemy), 20 * Time.deltaTime);
        }
        else
        {
            lookAtEnemy = transform.position;
        }
    }

    bool ShouldEquip()
    {
        bool result = false;
        //if (animator.GetCurrentAnimatorStateInfo(0).IsName("Base Layer.Standing Melee Attack Combo3"))
        if(animator.GetCurrentAnimatorStateInfo(0).IsName("Base Layer.Equip") &&
                animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 0.6)
        {
            result = true;
        }
        return result;
    }

    bool ShouldUnEquip()
    {
        bool result = false;
        if (animator.GetCurrentAnimatorStateInfo(0).IsName("Base Layer.UnEquip") &&
                animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 0.6)
        {
            result = true;
        }
        return result;
    }


    //stop actural melee attack and unequip sword
    bool StopMeleeAttack()
    {
        bool result = false;
        //if (Vector3.Distance(RemyMovement.destination, this.transform.position) < 1.0f)
        //{
        //    result = true;
        //}

        //if doesn't move
        if (Vector3.Distance(RemyMovement.destination, this.transform.position) > 1.0f)
        {
            Debug.Log("Destination: " + RemyMovement.destination);
            Debug.Log("This Position: " + this.transform.position);
            result = true;
        }

        return result;
    }
    void EquipSword()
    {
        swordOnHand.SetActive(true);
        swordOnBack.SetActive(false);
        //Debug.Log("拿剑");
    }

    void UnEquipSword()
    {
        swordOnHand.SetActive(false);
        swordOnBack.SetActive(true);
    }
}
