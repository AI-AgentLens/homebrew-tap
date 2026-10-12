cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2414"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2414/agentshield_0.2.2414_darwin_amd64.tar.gz"
      sha256 "94a2dbeea46ad53ea645f844bb14eda7aae4961ede8a71873371ffad331cece9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2414/agentshield_0.2.2414_darwin_arm64.tar.gz"
      sha256 "bb883fe3a8bc127b63f4750459f4a07999a195a642ea03c92cef5ab44458779d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2414/agentshield_0.2.2414_linux_amd64.tar.gz"
      sha256 "8e1bf357c8471d633451678d1ae8586c15e01e2e625aae3ffda1e868a591c4dd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2414/agentshield_0.2.2414_linux_arm64.tar.gz"
      sha256 "4bc1baafda40c22ad944a0a06e51b58781792df2bc07092d6111b1d998ac170f"
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
