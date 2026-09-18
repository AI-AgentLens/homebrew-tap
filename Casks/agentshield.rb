cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2173"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2173/agentshield_0.2.2173_darwin_amd64.tar.gz"
      sha256 "f38c45cdebff421a05dd28b1ed3578a6450036b45cf145a104771e7818ee77a0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2173/agentshield_0.2.2173_darwin_arm64.tar.gz"
      sha256 "919cbe198f4d84c513c4c9fd4c602414ab0ebbce3c2ac67a42fa4ee8d1ad782a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2173/agentshield_0.2.2173_linux_amd64.tar.gz"
      sha256 "39d99b065db0b0b72b1b2cefab5ecff3445cd40694dfdf129b482d838746524a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2173/agentshield_0.2.2173_linux_arm64.tar.gz"
      sha256 "d0796c49921e43ba86bd5ddffa22f0f0cf25eeedf0fac5d376e9d12a256c71de"
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
