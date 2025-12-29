using UnityEngine;

public class Recent_Blocker : MonoBehaviour
{
    [Header("Source")]
    public Recent_ID recentIDManager;   // assign the Recent_ID script here
    public GameObject blockingObject;   // object to show/hide when no recentID

    void Start()
    {
        if (blockingObject != null)
            blockingObject.SetActive(false); // default: hidden
    }

    void Update()
    {
        if (recentIDManager == null || blockingObject == null)
            return;

        // Show blocking object if recentID is null or empty, hide otherwise
        bool shouldBlock = string.IsNullOrEmpty(recentIDManager.recentID);
        blockingObject.SetActive(shouldBlock);
    }
}
