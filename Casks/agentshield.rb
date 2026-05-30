cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1153"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1153/agentshield_0.2.1153_darwin_amd64.tar.gz"
      sha256 "fb21f3c79f29306bf29d9e7f8f8cd9b2a7764ba994e103a045b0110b91ec4526"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1153/agentshield_0.2.1153_darwin_arm64.tar.gz"
      sha256 "8f1934731e21f11b205a3a76e5c030827666e7df667d54023636ad17c7ffc490"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1153/agentshield_0.2.1153_linux_amd64.tar.gz"
      sha256 "b74ea11e1748600617f805283ea918fc110585eb43fa20fe6850c0a319fa1945"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1153/agentshield_0.2.1153_linux_arm64.tar.gz"
      sha256 "fa9d5f5e89a07d3a17fb738f58c1c4d696b537faf5b58ccf9e81adf865d5db69"
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
