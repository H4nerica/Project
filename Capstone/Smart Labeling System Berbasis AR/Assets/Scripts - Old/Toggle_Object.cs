using UnityEngine;
using Vuforia;

public class Toggle_Object : MonoBehaviour
{
    public GameObject imageTarget;    // assign the Image Target here
    public GameObject objectToToggle; // object to hide/show

    private ObserverBehaviour observer;

    void Start()
    {
        if (imageTarget != null)
        {
            observer = imageTarget.GetComponent<ObserverBehaviour>();
            if (observer != null)
                observer.OnTargetStatusChanged += OnStatusChanged;
        }

        if (objectToToggle != null)
            objectToToggle.SetActive(true); // default: shown
    }

    private void OnStatusChanged(ObserverBehaviour behaviour, TargetStatus status)
    {
        bool isTracking = status.Status == Status.TRACKED && status.StatusInfo == StatusInfo.NORMAL;

        if (objectToToggle != null)
            objectToToggle.SetActive(!isTracking); // hide if tracked, show if not
    }
}
