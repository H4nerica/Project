using UnityEngine;

public class ChildFollowParents : MonoBehaviour
{
    RectTransform rt;
    Vector3 editorLocalPos;

    void Awake()
    {
        rt = GetComponent<RectTransform>();
        editorLocalPos = rt.localPosition; // ← store editor layout
    }

    void LateUpdate()
    {
        // restore relative position after parent moves
        rt.localPosition = editorLocalPos;
    }
}
