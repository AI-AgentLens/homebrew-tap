cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2213"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2213/agentshield_0.2.2213_darwin_amd64.tar.gz"
      sha256 "62de791e2513eebb536a16813d84a62d6ed82bbd23af9d9dbf0e363de322a254"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2213/agentshield_0.2.2213_darwin_arm64.tar.gz"
      sha256 "bc1d25d9c81ff15877c918551487fc973f33f04b45f20a994c71a0314654c1da"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2213/agentshield_0.2.2213_linux_amd64.tar.gz"
      sha256 "2dca31a8aa01919449b2ab491b7c81fb5ef74a028780ffb4c0d5d731d3f8ca1b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2213/agentshield_0.2.2213_linux_arm64.tar.gz"
      sha256 "686d9c0ab83b2a77efc63318bb6bec81946f47f1c17876154527780bd5eee245"
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
