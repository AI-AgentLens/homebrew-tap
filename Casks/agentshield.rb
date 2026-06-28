cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1478"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1478/agentshield_0.2.1478_darwin_amd64.tar.gz"
      sha256 "c03fab1ecd910014d07436ce110b215686854b881e1ba74869a6848d326925d7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1478/agentshield_0.2.1478_darwin_arm64.tar.gz"
      sha256 "fc2ae91b71c9a49b0dc6c96dc3d0445acc2ace778d4a157bfd7b8abb44b693f0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1478/agentshield_0.2.1478_linux_amd64.tar.gz"
      sha256 "04ac8f337f3ba47c5f74077bd31ca18d01f5b2cca88b0b991f533a3af8b69739"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1478/agentshield_0.2.1478_linux_arm64.tar.gz"
      sha256 "d05578a8c5ea9a67c7af8f26768d03d12f333a9e1473347c0425f67abb296d2a"
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
