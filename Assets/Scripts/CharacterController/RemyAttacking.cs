﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RemyAttacking : MonoBehaviour
{
    public static Vector3 attackDirection;
    public static Ability ability;
    


    private Animator animator;
    private Vector3 lookAtEnemy;
    private float EPSSION;
    private Vector3 lastDestination;

    public GameObject swordOnHand;
    public GameObject swordOnBack;
    


    // Start is called before the first frame update
    void Start()
    {
        animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        RotateToEnemy();

        //MeleeAttack();

        //if (ShouldEquip())
        //{
        //    EquipSword();
        //}

        if (StopMeleeAttack())
        {
            animator.SetBool("isIdleToMelee", false);
        }

        if (StopMagicAttack())
        {
            animator.SetBool("isIdleToMagic", false);
        }

        //if (ShouldUnEquip())
        //{
        //    UnEquipSword();
        //}

        //MagicAttack();

    }

    public void MeleeAttack()
    {
        RotateToEnemy();
        animator.SetBool("isIdleToMelee", true);

    }

    public void MagicAttack()
    {
        RotateToEnemy();
        animator.SetBool("isIdleToMagic", true);

    }

    void RotateToEnemy()
    {
        if (animator.GetCurrentAnimatorStateInfo(0).IsName("Base Layer.Standing Melee Attack Combo3")
            || animator.GetCurrentAnimatorStateInfo(0).IsName("Base Layer.Magic Attack 01")
            ) {
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
        if (animator.GetCurrentAnimatorStateInfo(0).IsName("Base Layer.Standing Melee Attack Combo3") &&
                animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 0.8)
        {
            result = true;
        }
        return result;
    }

    bool StopMagicAttack()
    {
        bool result = false;
        if (animator.GetCurrentAnimatorStateInfo(0).IsName("Base Layer.Magic Attack 01") &&
                animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 0.8)
        {
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

    void DoNotFly()
    {
        attackDirection.y = this.transform.position.y;
    }
}
