cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1713"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1713/agentshield_0.2.1713_darwin_amd64.tar.gz"
      sha256 "b70667e42b4b71d6ae678a0f2115bb6c15d92f9881854f76cf44b9d5c962587f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1713/agentshield_0.2.1713_darwin_arm64.tar.gz"
      sha256 "a8eeefdbadd687c9cc35f0a68566a693d3085beb57e171272535a8230dffe162"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1713/agentshield_0.2.1713_linux_amd64.tar.gz"
      sha256 "98daff968bc0e786a627cfe204726f9f9b1c50ebd86a16e9f21effb80bbc8b86"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1713/agentshield_0.2.1713_linux_arm64.tar.gz"
      sha256 "d52c297e8aee88a073a035f9a9e926c026aa3510381de67ee09d7c90ca643f50"
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
