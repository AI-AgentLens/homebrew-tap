cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1328"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1328/agentshield_0.2.1328_darwin_amd64.tar.gz"
      sha256 "9a979cde70e0a9fb45177e7bb6feaf66d4a062c480db4cd3f1d0ff71b1df5fcc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1328/agentshield_0.2.1328_darwin_arm64.tar.gz"
      sha256 "a9455dc9fea9ce453227fc34ab084af55b752561978139f78981f6396238e95b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1328/agentshield_0.2.1328_linux_amd64.tar.gz"
      sha256 "22bc9ea027437531747a287c29d5a86bdd9e32f194014ab6ff52da1cf369dd81"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1328/agentshield_0.2.1328_linux_arm64.tar.gz"
      sha256 "cf7110d9a3bcb0bbb1500457953708f702a2d241763b3a3a19dfd084063de743"
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
