cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1743"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1743/agentshield_0.2.1743_darwin_amd64.tar.gz"
      sha256 "bde62b30ac9c2a7b0a6d24982581a4bbedf6bf59ad82595061312998905def60"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1743/agentshield_0.2.1743_darwin_arm64.tar.gz"
      sha256 "2f9af242dece9e106b8f54fb2be203a551f58903b810ab6cd9dfd8f3943e1384"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1743/agentshield_0.2.1743_linux_amd64.tar.gz"
      sha256 "b209b69530027f222247471216aea6e844e88f2a2446b4b699212e6ccbdd8d01"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1743/agentshield_0.2.1743_linux_arm64.tar.gz"
      sha256 "8a87332e25ece4b958077d61b0d68790a45a50107f670d7eca653b6f5db8b15f"
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
