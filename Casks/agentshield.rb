cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.324"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.324/agentshield_0.2.324_darwin_amd64.tar.gz"
      sha256 "c11d01cd84f088899b886b7512510567f009af03471bb6bdd2218394fee467d9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.324/agentshield_0.2.324_darwin_arm64.tar.gz"
      sha256 "a7bc83a76d4f62f91e3d93604155c470583f5db3e641ee31b256369cb3bbadba"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.324/agentshield_0.2.324_linux_amd64.tar.gz"
      sha256 "d2db7a5778b0a8601e5ee5dd198163a7efb4b09a2d816bec69806b7b75336c32"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.324/agentshield_0.2.324_linux_arm64.tar.gz"
      sha256 "70246a1b40410f8f2b78d6793728dec8c8037bef0d2d6e6a1b4e4308bdcb5892"
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
