cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.790"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.790/agentshield_0.2.790_darwin_amd64.tar.gz"
      sha256 "0f398015bad843808e45b41760dd1304314901fa91a30c9562a3dab99305d7fc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.790/agentshield_0.2.790_darwin_arm64.tar.gz"
      sha256 "fbcb28f34264d89953fae0e456cec1022c88548d7c0aae7a86387ebd05202f46"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.790/agentshield_0.2.790_linux_amd64.tar.gz"
      sha256 "5b0ac94702deb5de0574953061daa3ac17b704642489f5fc426a75585b5d91ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.790/agentshield_0.2.790_linux_arm64.tar.gz"
      sha256 "b5cba038d75f9e274abc6f9871cdd1e204f20671cfafd447f5ca0130e4e944c3"
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
