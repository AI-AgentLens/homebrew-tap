cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.173"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.173/agentshield_0.2.173_darwin_amd64.tar.gz"
      sha256 "372aaba0f53de40b9be81f8494f438ce52040f955fae4b3eb87ccbc1c2f48b94"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.173/agentshield_0.2.173_darwin_arm64.tar.gz"
      sha256 "38989910b5f317254eb0a0db8b2d7832f173a8670a42f37ccd2448b3fbd11c32"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.173/agentshield_0.2.173_linux_amd64.tar.gz"
      sha256 "43b7e46de0947d8f42eb4b42364dd2605940d46efc61260a3fea22ff536328e4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.173/agentshield_0.2.173_linux_arm64.tar.gz"
      sha256 "73323e8196af755f3ce1411d670046171538a32481d0eb7d3e45d9e4958d9384"
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
