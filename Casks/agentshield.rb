cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.328"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.328/agentshield_0.2.328_darwin_amd64.tar.gz"
      sha256 "7b619f2a799a2c2bd0e784e1bc0d9a63c1de2b388525325754e3a8d88a807648"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.328/agentshield_0.2.328_darwin_arm64.tar.gz"
      sha256 "8ad4959a66c6e09cb17ca838fe2716fbd2229e58f93da30cea263be440da8d87"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.328/agentshield_0.2.328_linux_amd64.tar.gz"
      sha256 "4cde44a1e9094b0a8b2292af3b2d119644f4a8d3bff2617c03974a87d2a0bdf2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.328/agentshield_0.2.328_linux_arm64.tar.gz"
      sha256 "f3a708bdea5d94a75856bb071ff8d7d8bd92daddb7b0330447bbdc69dad5914a"
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
