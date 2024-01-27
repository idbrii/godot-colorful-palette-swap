tool
extends WindowDialog

func _on_process_complete():
    # Close the popup when processing completes.
    queue_free()

