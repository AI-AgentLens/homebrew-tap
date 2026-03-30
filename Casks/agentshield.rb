cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.227"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.227/agentshield_0.2.227_darwin_amd64.tar.gz"
      sha256 "dd128e17e3640ba0b4c2afb8cc76f8728cc1c1baea317845b245d8aa16e1713a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.227/agentshield_0.2.227_darwin_arm64.tar.gz"
      sha256 "5f611e87f57ec4b289ed9d34d7aad42a42c067c8f2806cc84e8c92fbbcdb07d4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.227/agentshield_0.2.227_linux_amd64.tar.gz"
      sha256 "73be7d63f06878f56d2e5b8c257bbd11c43988ef2478da8f8591485059613942"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.227/agentshield_0.2.227_linux_arm64.tar.gz"
      sha256 "81a401cea21d3c9ab3a21438ba4799f5516fb6b6b00d0e76fea89b3ac3326e35"
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
