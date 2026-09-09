cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2101"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2101/agentshield_0.2.2101_darwin_amd64.tar.gz"
      sha256 "c029ba5b4b3465456cc56a5188658ae01ff4455b0254c280829578af0cd0de55"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2101/agentshield_0.2.2101_darwin_arm64.tar.gz"
      sha256 "552575fa85495bca641dd3515bd615582ee12c60385f4bd6f2fbd04c2a479d86"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2101/agentshield_0.2.2101_linux_amd64.tar.gz"
      sha256 "de574d405c6a04f80e95f95db771ce650e623858c5ed5d75979176a0635cbe3a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2101/agentshield_0.2.2101_linux_arm64.tar.gz"
      sha256 "226d408af07c2c14f6042a47c390b0325bfccf62215223aa933cc633c64729a5"
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
