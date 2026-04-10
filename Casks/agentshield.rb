cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.527"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.527/agentshield_0.2.527_darwin_amd64.tar.gz"
      sha256 "6b4a4d17b3ab35e6383180bf63578e2d9e50a04dc9a2da85d2378b506ef967e8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.527/agentshield_0.2.527_darwin_arm64.tar.gz"
      sha256 "1dc6dce21d60f2dd9ac05a664fafd17dc5949eae4556ade106d4520b0664f161"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.527/agentshield_0.2.527_linux_amd64.tar.gz"
      sha256 "56a5e09c007809415cf3ae5b1db492aa57a371d0435e0cb6445230648cd5dc59"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.527/agentshield_0.2.527_linux_arm64.tar.gz"
      sha256 "04094901aba3a85b56143577d76f9809555d5468162d9652b46640c9fbe8dd10"
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
