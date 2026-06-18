function gback --description "Safely undo the last Git commit but keep file changes"
    # Check if we are actually inside a Git repository
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo (set_color red)"❌ Error: Not a git repository!"(set_color normal)
        return 1
    end

    # Soft reset rewinds the branch pointer by 1 commit without touching your files
    echo (set_color yellow)"⏪ Undoing last commit safely (keeping modifications)..."(set_color normal)
    git reset --soft HEAD~1
    
    echo (set_color green)"✨ Done! Check 'git status' to see your uncommitted files."(set_color normal)
end

