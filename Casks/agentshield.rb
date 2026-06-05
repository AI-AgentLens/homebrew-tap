cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1208"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1208/agentshield_0.2.1208_darwin_amd64.tar.gz"
      sha256 "e6fcc655d5b250f16a595506ee2dacc1eaea4fab6047794c0b0ac6d9d797632a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1208/agentshield_0.2.1208_darwin_arm64.tar.gz"
      sha256 "1cb4e96288d99a7e0a3d55132f0472a65a6c720a751a8f79206eb81dd9318a9d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1208/agentshield_0.2.1208_linux_amd64.tar.gz"
      sha256 "128607314a46e2e60eba8c6b1dcb787999123a5e03e91d68df95270cf23e4c98"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1208/agentshield_0.2.1208_linux_arm64.tar.gz"
      sha256 "e4aa4258e71b9d25f65e28858dbfd15a01a7588fbcee5e873d8e82dc9cc5c483"
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
