cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2400"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2400/agentshield_0.2.2400_darwin_amd64.tar.gz"
      sha256 "5cbb58314611710eb7c011110b0006edff759dc666ea063c19ab2d3d7f95986d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2400/agentshield_0.2.2400_darwin_arm64.tar.gz"
      sha256 "049f36f66bb7133742838c532a85fec43fef90bff7c4d822cf75a0631765dd14"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2400/agentshield_0.2.2400_linux_amd64.tar.gz"
      sha256 "068a262ec3c34995b543d6722ab5fa2d06eeba2e9001cdb5e42988459225eb59"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2400/agentshield_0.2.2400_linux_arm64.tar.gz"
      sha256 "f7420fb333ae03296a68130606941b09e8309aa6bb87fd4bf35f9bf99f075ee0"
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
