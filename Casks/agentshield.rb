cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.698"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.698/agentshield_0.2.698_darwin_amd64.tar.gz"
      sha256 "42831ebaf1e74ed9ae410ff77c0e0cbda3ff01bb12bddeb0b9bbd374ebd191ee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.698/agentshield_0.2.698_darwin_arm64.tar.gz"
      sha256 "8d30e7dc765e9c43caffc41f6433325c0b501437518a297d02bc77e5bed8e284"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.698/agentshield_0.2.698_linux_amd64.tar.gz"
      sha256 "150b00288b349a572c1c98b031cfbbcef350e475f45b7a0a6787b3d22e1b059f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.698/agentshield_0.2.698_linux_arm64.tar.gz"
      sha256 "4bf30f597849d5d90a5ad2d4e1ce273cfd231cb9544c07043b170deeb083a842"
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
