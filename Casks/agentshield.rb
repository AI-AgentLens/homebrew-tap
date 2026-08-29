cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1982"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1982/agentshield_0.2.1982_darwin_amd64.tar.gz"
      sha256 "151729c499c24a95c3a5b7290604ced5a1b77bfebfb13795f8bd3c52244c889a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1982/agentshield_0.2.1982_darwin_arm64.tar.gz"
      sha256 "7b86f6ec712e26cda18c28eb543af1ee6d284f0dce0c27b07e9170e11d8d2bfe"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1982/agentshield_0.2.1982_linux_amd64.tar.gz"
      sha256 "696ea79af45c3cc2de343c076477a0e96b9678bbb3981ea7afc2e993a2d68a97"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1982/agentshield_0.2.1982_linux_arm64.tar.gz"
      sha256 "f928b2f7a4ee9a919c5445e8b20b39999d9e9e42b75172abc906c4b0ae035519"
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
