cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1053"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1053/agentshield_0.2.1053_darwin_amd64.tar.gz"
      sha256 "909193125f305b5d74fd2f9b0e19b73dd49553bf27abd1e1867917647b61744c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1053/agentshield_0.2.1053_darwin_arm64.tar.gz"
      sha256 "4b72f1c9cc8611637309a50e71889da83447e491ecfeabed6bb7e6d63dab774a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1053/agentshield_0.2.1053_linux_amd64.tar.gz"
      sha256 "22f2b30decc40a882e9ade23bf00d45fabded978a5c9ac622ce21b277a500e04"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1053/agentshield_0.2.1053_linux_arm64.tar.gz"
      sha256 "b0c197f436b096746e85b2d7b59ecff300add841d59f200382dcceb71ba4a542"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
