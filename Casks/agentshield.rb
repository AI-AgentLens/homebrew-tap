cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.351"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.351/agentshield_0.2.351_darwin_amd64.tar.gz"
      sha256 "05bc38d8fc4f0fa3d9bf14bd6776d1e618bb9be83395cca3dc26709b2bb8db89"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.351/agentshield_0.2.351_darwin_arm64.tar.gz"
      sha256 "c7abf09a1ad7c53d1e599114e9a0d5c078a5722be1ae5929ca13506ffea8d3f4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.351/agentshield_0.2.351_linux_amd64.tar.gz"
      sha256 "0ffdf17aba99684ba334b03a473c533f8d8bd5f216a93beab28d8974d69a7be5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.351/agentshield_0.2.351_linux_arm64.tar.gz"
      sha256 "a784fa93567b03d1772904375dd1b39a9b0ee94abd14fa7a1b8634ac6628595b"
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
