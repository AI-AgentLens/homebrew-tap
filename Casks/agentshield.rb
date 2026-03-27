cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.109"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.109/agentshield_0.2.109_darwin_amd64.tar.gz"
      sha256 "671f1c5fbffaaa52fea8f5145417f939e0e5dc349e8db6ee10029e927081a359"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.109/agentshield_0.2.109_darwin_arm64.tar.gz"
      sha256 "d062fd94184057c8d49d3a267d8be06be9ebb4aeee53e7f67381f449873587ca"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.109/agentshield_0.2.109_linux_amd64.tar.gz"
      sha256 "c497638e42bf79ce6a8e857e067389aa83d068aa189df4138a6307212d489bf4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.109/agentshield_0.2.109_linux_arm64.tar.gz"
      sha256 "3271c90d76a5c4b4ce9f7e47c729d3ee23dec5d5337640920493f06120368891"
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
