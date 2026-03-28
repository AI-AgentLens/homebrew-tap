cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.151"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.151/agentshield_0.2.151_darwin_amd64.tar.gz"
      sha256 "91f9e5bffbd6d351fef9e0ed298c92f64f3d3f9f6f1ce7f8ec5b7518bdd5c926"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.151/agentshield_0.2.151_darwin_arm64.tar.gz"
      sha256 "5b4b20dc8730eb8da80d077f8833a3f8aef1a96c65720128feac721ace951e6d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.151/agentshield_0.2.151_linux_amd64.tar.gz"
      sha256 "397af25c80f5a3b08c6b1b19ea0afb4d051fb4023dd5d9a1d2910e0d322b77a9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.151/agentshield_0.2.151_linux_arm64.tar.gz"
      sha256 "e1799986ae6df7c837a35d827062f6010281ae1b36377a87158e34d11f9785d5"
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
